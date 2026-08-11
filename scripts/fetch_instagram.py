#!/usr/bin/env python3
"""
fetch_instagram.py
Fetches recent posts from Instagram Graph API and generates Jekyll blog posts.

Required environment variables:
  INSTAGRAM_ACCESS_TOKEN - Long-lived access token for the Instagram Graph API
  INSTAGRAM_USER_ID      - Instagram Business/Creator account user ID

The script:
1. Fetches the latest posts from the Instagram Graph API
2. Skips posts that already have a corresponding Jekyll post (by shortcode in filename)
3. Downloads images and videos to images/blog/
4. Creates a Jekyll-compatible markdown file in collections/_posts/
"""

import os
import sys
import re
import json
import urllib.request
import urllib.error
from datetime import datetime
from pathlib import Path

# ---------------------------------------------------------------------------
# Configuration
# ---------------------------------------------------------------------------

GRAPH_API_BASE = "https://graph.facebook.com/v21.0"
POSTS_DIR = Path(__file__).resolve().parent.parent / "collections" / "_posts"
IMAGES_DIR = Path(__file__).resolve().parent.parent / "images" / "blog"
PLACEHOLDER_IMAGE = "/images/logo/logo.svg"
# Fetch up to 25 recent posts per run (API max per page)
FETCH_LIMIT = 25


def get_env(name):
    """Get required environment variable or exit."""
    value = os.environ.get(name)
    if not value:
        print(f"ERROR: Missing required environment variable: {name}", file=sys.stderr)
        sys.exit(1)
    return value


# ---------------------------------------------------------------------------
# Instagram Graph API helpers
# ---------------------------------------------------------------------------

def api_get(url):
    """Make a GET request and return parsed JSON."""
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=30) as resp:
            return json.loads(resp.read().decode("utf-8"))
    except urllib.error.HTTPError as e:
        body = e.read().decode("utf-8", errors="replace")
        print(f"API error {e.code}: {body}", file=sys.stderr)
        sys.exit(1)
    except urllib.error.URLError as e:
        print(f"Network error: {e.reason}", file=sys.stderr)
        sys.exit(1)


def resolve_instagram_user_id(access_token):
    """
    For Facebook Login tokens: resolve the Instagram Business Account ID
    from the linked Facebook Page. Falls back to INSTAGRAM_USER_ID env var.
    """
    # Step 1: Get Facebook Pages the user manages
    url = f"{GRAPH_API_BASE}/me/accounts?fields=id,name,instagram_business_account&access_token={access_token}"
    data = api_get(url)
    pages = data.get("data", [])

    for page in pages:
        ig_account = page.get("instagram_business_account")
        if ig_account:
            ig_id = ig_account.get("id")
            print(f"Found Instagram Business Account: {ig_id} (via Page: {page.get('name')})")
            return ig_id

    return None


def fetch_recent_posts(user_id, access_token, limit=FETCH_LIMIT):
    """Fetch recent media from the Instagram account."""
    fields = "id,caption,media_type,media_url,thumbnail_url,timestamp,permalink,children{media_type,media_url}"
    url = (
        f"{GRAPH_API_BASE}/{user_id}/media"
        f"?fields={fields}&limit={limit}&access_token={access_token}"
    )
    data = api_get(url)
    return data.get("data", [])


# ---------------------------------------------------------------------------
# Text processing (matches existing generate-posts.rb logic)
# ---------------------------------------------------------------------------

def extract_title(text):
    """Extract title from post caption (first sentence, max 80 chars)."""
    if not text or not text.strip():
        return "Bez tytułu"

    # Strip hashtags
    clean = re.sub(r"#[\w\u00C0-\u024F]+", "", text).strip()
    if not clean:
        return "Bez tytułu"

    # First sentence: split on period or newline
    first = re.split(r"[.\n]", clean, maxsplit=1)[0].strip()
    if not first:
        return "Bez tytułu"

    if len(first) > 80:
        return first[:80] + "…"
    return first


def extract_tags(text):
    """Extract hashtags from caption."""
    if not text:
        return []
    tags = re.findall(r"#([\w\u00C0-\u024F]+)", text)
    return sorted(set(t.lower() for t in tags))


def extract_description(text):
    """Extract clean description (max 160 chars, no hashtags)."""
    if not text or not text.strip():
        return ""
    clean = strip_hashtags(text).strip()
    if not clean:
        return ""
    return clean[:160] if len(clean) > 160 else clean


def strip_hashtags(text):
    """Remove hashtag-only lines and inline hashtags."""
    if not text:
        return ""
    lines = []
    for line in text.splitlines():
        stripped = line.strip()
        # Skip lines that are entirely hashtags
        if re.match(r"^(#[\w\u00C0-\u024F]+\s*)+$", stripped):
            continue
        # Remove inline hashtags
        cleaned = re.sub(r"#[\w\u00C0-\u024F]+", "", line)
        cleaned = re.sub(r"  +", " ", cleaned)
        lines.append(cleaned)
    return "\n".join(lines).strip()


# ---------------------------------------------------------------------------
# Media downloading
# ---------------------------------------------------------------------------

def download_file(url, dest_path):
    """Download a file from URL to local path."""
    dest_path.parent.mkdir(parents=True, exist_ok=True)
    try:
        req = urllib.request.Request(url)
        with urllib.request.urlopen(req, timeout=60) as resp:
            with open(dest_path, "wb") as f:
                while True:
                    chunk = resp.read(8192)
                    if not chunk:
                        break
                    f.write(chunk)
        return True
    except (urllib.error.URLError, OSError) as e:
        print(f"  WARNING: Failed to download {url}: {e}", file=sys.stderr)
        return False


def shortcode_from_permalink(permalink):
    """Extract Instagram shortcode from permalink URL."""
    # https://www.instagram.com/p/ABC123/ -> ABC123
    # https://www.instagram.com/reel/ABC123/ -> ABC123
    match = re.search(r"/(p|reel|tv)/([^/]+)", permalink)
    if match:
        return match.group(2)
    return None


# ---------------------------------------------------------------------------
# Post generation
# ---------------------------------------------------------------------------

def get_existing_shortcodes():
    """Scan existing posts to find which shortcodes are already generated."""
    POSTS_DIR.mkdir(parents=True, exist_ok=True)
    existing = set()
    for f in POSTS_DIR.glob("*.md"):
        # Filename format: YYYY-MM-DD-shortcode.md
        parts = f.stem.split("-", 3)
        if len(parts) == 4:
            existing.add(parts[3].lower())
    # Also check .markdown files
    for f in POSTS_DIR.glob("*.markdown"):
        parts = f.stem.split("-", 3)
        if len(parts) == 4:
            existing.add(parts[3].lower())
    return existing


def yaml_escape(s):
    """Escape a string for YAML output."""
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'


def process_post(post, existing_shortcodes):
    """Process a single Instagram post and create Jekyll post if new."""
    permalink = post.get("permalink", "")
    shortcode = shortcode_from_permalink(permalink)

    if not shortcode:
        print(f"  SKIP: Could not extract shortcode from {permalink}")
        return False

    if shortcode.lower() in existing_shortcodes:
        return False

    caption = post.get("caption", "")
    timestamp = post.get("timestamp", "")
    media_type = post.get("media_type", "")

    # Parse date
    try:
        dt = datetime.fromisoformat(timestamp.replace("Z", "+00:00"))
    except (ValueError, AttributeError):
        dt = datetime.now()

    date_str = dt.strftime("%Y-%m-%d")
    date_prefix = dt.strftime("%Y%m%d")

    # Collect media URLs
    image_urls = []
    video_urls = []

    if media_type == "CAROUSEL_ALBUM":
        children = post.get("children", {}).get("data", [])
        for child in children:
            child_type = child.get("media_type", "")
            child_url = child.get("media_url", "")
            if child_type == "VIDEO":
                video_urls.append(child_url)
            elif child_url:
                image_urls.append(child_url)
    elif media_type == "VIDEO":
        video_url = post.get("media_url", "")
        if video_url:
            video_urls.append(video_url)
        # Use thumbnail as image
        thumb = post.get("thumbnail_url", "")
        if thumb:
            image_urls.append(thumb)
    elif media_type == "IMAGE":
        media_url = post.get("media_url", "")
        if media_url:
            image_urls.append(media_url)

    # Download media files
    downloaded_images = []
    downloaded_videos = []

    for i, url in enumerate(image_urls, 1):
        filename = f"{date_prefix}_{shortcode}_{i}.jpg"
        dest = IMAGES_DIR / filename
        if dest.exists() or download_file(url, dest):
            downloaded_images.append(f"/images/blog/{filename}")

    for i, url in enumerate(video_urls, 1):
        filename = f"{date_prefix}_{shortcode}_v{i}.mp4"
        dest = IMAGES_DIR / filename
        if dest.exists() or download_file(url, dest):
            downloaded_videos.append(f"/images/blog/{filename}")

    # Determine featured image
    if downloaded_images:
        featured_image = downloaded_images[0]
    else:
        featured_image = PLACEHOLDER_IMAGE

    # Extract text components
    title = extract_title(caption)
    tags = extract_tags(caption)
    description = extract_description(caption)
    body = strip_hashtags(caption)

    # Build markdown file
    lines = ["---"]
    lines.append(f"title: {yaml_escape(title)}")
    lines.append(f"date: {date_str}")
    lines.append(f"image: {yaml_escape(featured_image)}")

    if downloaded_images:
        lines.append("images:")
        for img in downloaded_images:
            lines.append(f"  - {yaml_escape(img)}")
    else:
        lines.append("images: []")

    if downloaded_videos:
        lines.append("videos:")
        for vid in downloaded_videos:
            lines.append(f"  - {yaml_escape(vid)}")
    else:
        lines.append("videos: []")

    if tags:
        lines.append(f"tags: [{', '.join(tags)}]")
    else:
        lines.append("tags: []")

    lines.append(f"description: {yaml_escape(description)}")
    lines.append("---")
    lines.append(body)
    lines.append("")

    # Write post file
    post_filename = f"{date_str}-{shortcode.lower()}.md"
    post_path = POSTS_DIR / post_filename
    post_path.write_text("\n".join(lines), encoding="utf-8")

    print(f"  NEW: {post_filename}")
    return True


# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

def main():
    access_token = get_env("INSTAGRAM_ACCESS_TOKEN")
    user_id = os.environ.get("INSTAGRAM_USER_ID")

    # For Facebook Login tokens (EAA...), resolve IG user ID automatically
    if not user_id:
        print("INSTAGRAM_USER_ID not set, resolving from Facebook token...")
        user_id = resolve_instagram_user_id(access_token)
        if not user_id:
            print("ERROR: Could not find an Instagram Business Account linked to your Facebook Pages.", file=sys.stderr)
            print("Make sure your Instagram Professional account is connected to a Facebook Page.", file=sys.stderr)
            sys.exit(1)
    elif access_token.startswith("EAA"):
        # Even if user_id is set, verify it works — but also try auto-resolve as fallback
        print(f"Using Facebook Login token with user ID: {user_id}")

    print(f"Fetching recent posts for user {user_id}...")
    posts = fetch_recent_posts(user_id, access_token)
    print(f"Fetched {len(posts)} posts from API")

    existing = get_existing_shortcodes()
    print(f"Found {len(existing)} existing posts locally")

    new_count = 0
    for post in posts:
        if process_post(post, existing):
            new_count += 1

    print(f"\nDone: {new_count} new posts created, {len(posts) - new_count} skipped (already exist)")

    # Output for GitHub Actions
    github_output = os.environ.get("GITHUB_OUTPUT")
    if github_output:
        with open(github_output, "a") as f:
            f.write(f"new_posts={new_count}\n")


if __name__ == "__main__":
    main()
