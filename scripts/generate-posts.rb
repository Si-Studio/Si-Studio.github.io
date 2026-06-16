#!/usr/bin/env ruby
# frozen_string_literal: true

# generate-posts.rb
# Pre-build script: converts sistudio_content/ Instagram data into Jekyll _posts.
# Run from project root before `jekyll build`.

require 'fileutils'

CONTENT_DIR = File.join(__dir__, '..', 'sistudio_content')
OUTPUT_DIR = File.join(__dir__, '..', 'collections', '_posts')
PLACEHOLDER_IMAGE = '/images/logo/logo.svg'
DATE_PREFIX_REGEX = /\A(\d{4})(\d{2})(\d{2})_(.+)\z/

def extract_title(text)
  return 'Bez tytułu' if text.nil? || text.strip.empty?

  # Strip hashtags before extracting title
  clean_text = text.gsub(/#[\p{L}\p{N}_]+/, '').strip
  return 'Bez tytułu' if clean_text.empty?

  # First sentence: up to first period or newline
  first_sentence = clean_text.split(/[.\n]/, 2).first&.strip || ''
  return 'Bez tytułu' if first_sentence.empty?

  if first_sentence.length > 80
    first_sentence[0, 80] + '…'
  else
    first_sentence
  end
end

def extract_tags(text)
  return [] if text.nil?

  text.scan(/#([\p{L}\p{N}_]+)/).flatten.map(&:downcase).uniq
end

def extract_description(text)
  return '' if text.nil? || text.strip.empty?

  # Strip hashtags for clean description
  clean = strip_hashtags(text).strip
  return '' if clean.empty?
  clean.length > 160 ? clean[0, 160] : clean
end

def strip_hashtags(text)
  return '' if text.nil?

  # Remove lines that are entirely hashtags (common Instagram pattern)
  lines = text.lines.map do |line|
    stripped = line.strip
    # If a line is only hashtags (and spaces), remove it entirely
    if stripped.match?(/\A(#[\p{L}\p{N}_]+\s*)+\z/)
      nil
    else
      # Remove inline hashtags from mixed-content lines
      line.gsub(/#[\p{L}\p{N}_]+/, '').gsub(/\s{2,}/, ' ')
    end
  end.compact

  lines.join.strip
end

def find_images(stem)
  # stem is e.g. "20250321_DHdH8G2Mka_"
  # Look for: stem.jpg (unsuffixed) and stem_N.jpg (numbered)
  dir = CONTENT_DIR
  base_jpg = File.join(dir, "#{stem}.jpg")
  numbered_pattern = File.join(dir, "#{stem}_*.jpg")

  images = []

  # Check for unsuffixed image
  images << "#{stem}.jpg" if File.exist?(base_jpg)

  # Find numbered images
  Dir.glob(numbered_pattern).each do |path|
    filename = File.basename(path)
    # Extract suffix number: stem_N.jpg
    suffix_part = filename.delete_prefix("#{stem}_").delete_suffix('.jpg')
    # Only include if suffix is purely numeric
    next unless suffix_part.match?(/\A\d+\z/)

    images << filename
  end

  # Sort by numeric suffix (unsuffixed first, then by number)
  images.sort_by do |img|
    suffix_part = img.delete_prefix("#{stem}_").delete_suffix('.jpg')
    if suffix_part == "#{stem}.jpg".delete_suffix('.jpg')
      # This is the unsuffixed image (stem.jpg)
      -1
    else
      num = suffix_part.to_i
      num.zero? ? -1 : num
    end
  end
end

def sort_images(images, stem)
  images.sort_by do |img|
    basename = File.basename(img, '.jpg')
    if basename == stem
      -1 # unsuffixed comes first
    else
      suffix = basename.delete_prefix("#{stem}_")
      suffix.match?(/\A\d+\z/) ? suffix.to_i : 0
    end
  end
end

def find_videos(stem)
  dir = CONTENT_DIR
  videos = []

  # Check for unsuffixed video
  base_mp4 = File.join(dir, "#{stem}.mp4")
  videos << "#{stem}.mp4" if File.exist?(base_mp4)

  # Find numbered videos
  Dir.glob(File.join(dir, "#{stem}_*.mp4")).each do |path|
    filename = File.basename(path)
    suffix_part = filename.delete_prefix("#{stem}_").delete_suffix('.mp4')
    next unless suffix_part.match?(/\A\d+\z/)
    videos << filename
  end

  videos.sort_by do |vid|
    basename = File.basename(vid, '.mp4')
    if basename == stem
      -1
    else
      suffix = basename.delete_prefix("#{stem}_")
      suffix.match?(/\A\d+\z/) ? suffix.to_i : 0
    end
  end
end

def generate_post(txt_file, stem, year, month, day, shortcode)
  text = File.read(txt_file, encoding: 'utf-8').strip
  title = extract_title(text)
  tags = extract_tags(text)
  description = extract_description(text)
  body = strip_hashtags(text) # Fix 7: clean body without hashtags
  date_str = "#{year}-#{month}-#{day}"

  images = find_images(stem)
  images = sort_images(images, stem)
  videos = find_videos(stem)

  if images.empty? && videos.empty?
    featured_image = PLACEHOLDER_IMAGE
    images_array = []
    videos_array = []
  elsif images.any?
    featured_image = "/images/blog/#{images.first}"
    images_array = images.map { |img| "/images/blog/#{img}" }
    videos_array = videos.map { |vid| "/images/blog/#{vid}" }
  else
    # Only videos, no images — use placeholder for featured image (card thumbnail)
    featured_image = PLACEHOLDER_IMAGE
    images_array = []
    videos_array = videos.map { |vid| "/images/blog/#{vid}" }
  end

  # Build front matter
  front_matter = {
    'title' => title,
    'date' => date_str,
    'image' => featured_image,
    'images' => images_array,
    'videos' => videos_array,
    'tags' => tags,
    'description' => description
  }

  # Generate YAML front matter manually for clean output
  yaml_lines = ["---"]
  yaml_lines << "title: #{yaml_string(front_matter['title'])}"
  yaml_lines << "date: #{front_matter['date']}"
  yaml_lines << "image: #{yaml_string(front_matter['image'])}"

  if front_matter['images'].empty?
    yaml_lines << "images: []"
  else
    yaml_lines << "images:"
    front_matter['images'].each do |img|
      yaml_lines << "  - #{yaml_string(img)}"
    end
  end

  if front_matter['videos'].empty?
    yaml_lines << "videos: []"
  else
    yaml_lines << "videos:"
    front_matter['videos'].each do |vid|
      yaml_lines << "  - #{yaml_string(vid)}"
    end
  end

  if front_matter['tags'].empty?
    yaml_lines << "tags: []"
  else
    yaml_lines << "tags: [#{front_matter['tags'].join(', ')}]"
  end

  yaml_lines << "description: #{yaml_string(front_matter['description'])}"
  yaml_lines << "---"

  content = yaml_lines.join("\n") + "\n" + body + "\n"

  # Output filename: YYYY-MM-DD-shortcode.md
  output_filename = "#{date_str}-#{shortcode.downcase}.md"
  output_path = File.join(OUTPUT_DIR, output_filename)

  File.write(output_path, content)
  output_path
end

def yaml_string(str)
  # Wrap in quotes if contains special YAML characters
  if str.include?('"')
    "\"#{str.gsub('"', '\\"')}\""
  else
    "\"#{str}\""
  end
end

def main
  FileUtils.mkdir_p(OUTPUT_DIR)

  # Clean existing generated posts
  Dir.glob(File.join(OUTPUT_DIR, '*.md')).each { |f| File.delete(f) }

  txt_files = Dir.glob(File.join(CONTENT_DIR, '*.txt'))
  generated = 0
  skipped = 0

  txt_files.each do |txt_file|
    basename = File.basename(txt_file, '.txt')
    match = basename.match(DATE_PREFIX_REGEX)

    unless match
      warn "SKIP: Malformed filename '#{File.basename(txt_file)}' (does not match YYYYMMDD_SHORTCODE pattern)"
      skipped += 1
      next
    end

    year = match[1]
    month = match[2]
    day = match[3]
    shortcode = match[4]

    # Validate date components
    unless (1..12).include?(month.to_i) && (1..31).include?(day.to_i)
      warn "SKIP: Invalid date in '#{File.basename(txt_file)}'"
      skipped += 1
      next
    end

    generate_post(txt_file, basename, year, month, day, shortcode)
    generated += 1
  end

  puts "Generated #{generated} posts, skipped #{skipped} files"
end

main
