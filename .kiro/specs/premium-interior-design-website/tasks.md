jeky# Implementation Plan: Premium Interior Design Website

## Overview

Complete rebuild of the Si Studio interior design website using Jekyll 4.x with custom SCSS, vanilla JavaScript, and a Ruby pre-build script for Instagram content conversion. Implementation follows a layered approach: foundation (config, tokens, layouts) → content infrastructure (collections, build script) → components (navigation, hero, portfolio, blog, pages) → interactivity (animations, lightbox, form) → polish (SEO, performance, 404).

## Tasks

- [x] 1. Foundation: Configuration, Design Tokens, and Base Layout
  - [x] 1.1 Update `_config.yml` with new site configuration
    - Remove bookshop references and Tailwind/PostCSS excludes
    - Configure collections (projects, posts, pages) with correct output and permalink patterns
    - Set `collections_dir: 'collections'`
    - Add pagination settings, tag configuration, and site metadata (title: "Si Studio", description, url)
    - Ensure `jekyll-sitemap` plugin remains active
    - _Requirements: 14.1, 14.2, 14.4_

  - [x] 1.2 Create SCSS design tokens and base styles
    - Create `_sass/_variables.scss` with CSS custom properties: 5-color warm neutral palette, typography scale (Cormorant Garamond + Montserrat), spacing tokens, animation durations/easings
    - Create `_sass/_reset.scss` with CSS reset/normalize
    - Create `_sass/_typography.scss` with Google Fonts `@import` via preconnect, modular scale (ratio 1.25), `font-display: swap`
    - Create `_sass/_layout.scss` with responsive grid, max-width 1400px container, breakpoints (375px, 768px, 1024px)
    - Create `assets/css/main.scss` as Sass entry point importing all partials
    - _Requirements: 11.1, 11.2, 11.3, 11.4, 11.5, 11.6, 12.1, 12.4_

  - [x] 1.3 Create data files for navigation, colors, and services
    - Update `_data/navigation.yml` with logo path and 6 menu items (Home, Projekty, O Mnie, Blog, Oferta, Kontakt)
    - Create `_data/colors.yml` with palette values and RGB variants
    - Create `_data/services.yml` with service categories and process steps
    - _Requirements: 2.1, 6.1, 6.2, 12.1_

  - [x] 1.4 Create base `_layouts/default.html` layout
    - Include `_includes/head.html` (meta, fonts preconnect, CSS link)
    - Include loader markup inline at top of `<body>`
    - Include `_includes/header.html` (navigation)
    - `<main>` content block
    - Include `_includes/footer.html`
    - Include all JS files before `</body>` with `defer`
    - Use semantic HTML5 elements (header, nav, main, footer)
    - _Requirements: 14.1, 14.7, 15.3_

  - [x] 1.5 Create `_includes/head.html` with meta tags and font loading
    - Google Fonts preconnect + stylesheet links (Cormorant Garamond 400,500,600; Montserrat 300,400,500)
    - Open Graph meta tags from page front matter
    - Canonical URL tag
    - Viewport meta tag
    - CSS stylesheet link
    - _Requirements: 11.1, 11.2, 11.5, 15.1, 15.5_

- [x] 2. Navigation System
  - [x] 2.1 Create `_includes/header.html` with navigation markup
    - Fixed header with logo link, menu items from `_data/navigation.yml`
    - ARIA attributes: `aria-label="Nawigacja główna"`, `role="menubar"`, `aria-current="page"` on active link
    - Hamburger button with `aria-expanded`, `aria-controls="mobile-menu"`
    - Mobile overlay `<div>` with `role="dialog"`, `aria-modal="true"`
    - _Requirements: 2.1, 2.4, 2.6, 2.7_

  - [x] 2.2 Create `_sass/_navigation.scss` styles
    - Transparent → opaque scroll transition (300ms, backdrop-filter blur 8px)
    - Fixed positioning at top
    - Active link visual indicator (underline, non-color-dependent)
    - Mobile hamburger at < 768px, full-screen overlay
    - Staggered link animation (50–100ms per item, total ≤ 600ms)
    - `prefers-reduced-motion`: instant state changes
    - _Requirements: 2.2, 2.3, 2.5, 2.6, 2.7, 2.9_

  - [x] 2.3 Create `assets/js/navigation.js`
    - Scroll listener: toggle opaque class at 80px threshold
    - Mobile menu open/close toggle with `aria-expanded` state
    - Focus trap within mobile menu when open
    - Escape key closes menu, returns focus to hamburger
    - `prefers-reduced-motion` check: skip transitions
    - _Requirements: 2.2, 2.3, 2.4, 2.5, 2.8, 2.9_

- [x] 3. Page Loader
  - [x] 3.1 Create `_includes/loader.html` and `assets/js/loader.js`
    - Inline loader markup with Si Studio logo, fade-in + slide-up CSS animation
    - `loader.js`: listen for `DOMContentLoaded`, trigger fade-out (600ms), emit `si:page-ready` custom event
    - Force-hide timeout at 3000ms via `setTimeout`
    - Total markup + inline styles < 5KB
    - `prefers-reduced-motion`: show statically, hide instantly on ready
    - _Requirements: 16.1, 16.2, 16.3, 16.4, 16.6_

  - [x] 3.2 Create `_sass/_loader.scss`
    - Logo fade-in (300ms) + translateY(-20px → 0) animation
    - Fade-out transition (600ms opacity → 0, then display: none)
    - Page content initial hidden state, reveal on `.loader--hidden`
    - _Requirements: 16.1, 16.2_

- [x] 4. Hero Section
  - [x] 4.1 Create `_includes/hero.html` and `_sass/_hero.scss`
    - Full-viewport section (min-height: 100vh) with background image from project photography
    - Semi-transparent overlay for 4.5:1 contrast ratio on text
    - Studio name (h1) + tagline (< 80 chars) in serif typeface
    - Scroll indicator at bottom center with CSS bounce animation (2000ms cycle)
    - `aria-label` on section
    - _Requirements: 1.1, 1.2, 1.4_

  - [x] 4.2 Create `assets/js/parallax.js`
    - `requestAnimationFrame` loop applying `transform: translate3d(0, Ypx, 0)` at 0.3–0.5× scroll rate
    - Only active when `prefers-reduced-motion` is not set
    - Listen for `si:page-ready` event before starting text reveal animation (staggered, 1200ms total)
    - Hero image error fallback: set background-color to `var(--color-border)`
    - _Requirements: 1.3, 1.5, 1.6, 8.1, 8.3_

- [x] 5. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 6. Blog Engine: Build Script and Layouts
  - [x] 6.1 Create `scripts/generate-posts.rb` pre-build script
    - Scan `sistudio_content/` for `.txt` files
    - Parse filename: `YYYYMMDD_SHORTCODE.txt` → extract date
    - Extract title: first sentence (up to first `.` or `\n`), truncate at 80 chars + `…`
    - Find matching `.jpg` files (same prefix, optional `_N` suffixes), sort by numeric suffix ascending
    - Generate `_posts/YYYY-MM-DD-shortcode.md` with front matter (title, date, image, images array, tags from hashtags, description)
    - Handle edge cases: no matching jpg → use placeholder, empty text → title "Bez tytułu", malformed filenames → skip
    - _Requirements: 4.1, 4.2, 4.3, 4.5, 4.8, 14.8_

  - [x] 6.2 Write property tests for folder-name-to-title transformation (Ruby/rantly)
    - **Property 1: Folder Name to Display Title Transformation**
    - **Validates: Requirements 3.2**

  - [x] 6.3 Write property tests for blog post generation (Ruby/rantly)
    - **Property 2: Blog Post Generation from Instagram Content**
    - **Validates: Requirements 4.1**

  - [x] 6.4 Write property tests for date format transformation (Ruby/rantly)
    - **Property 3: Date Format Transformation**
    - **Validates: Requirements 4.2**

  - [x] 6.5 Write property tests for blog title extraction (Ruby/rantly)
    - **Property 4: Blog Title Extraction**
    - **Validates: Requirements 4.3**

  - [x] 6.6 Write property tests for image suffix ordering (Ruby/rantly)
    - **Property 5: Image Suffix Numerical Ordering**
    - **Validates: Requirements 4.5**

  - [x] 6.7 Write property tests for blog pagination invariants (Ruby/rantly)
    - **Property 6: Blog Pagination Invariants**
    - **Validates: Requirements 4.6**

  - [x] 6.8 Create `_layouts/blog.html` and `_layouts/post.html`
    - Blog index: 12 posts per page, reverse chronological, pagination controls
    - Post cards: featured image, extracted title, date in DD.MM.YYYY format
    - Individual post: full text, all images vertically stacked in suffix order
    - Scroll-triggered fade-up animation on cards (600ms)
    - _Requirements: 4.2, 4.3, 4.4, 4.5, 4.6, 4.7_

  - [x] 6.9 Create `_sass/_blog.scss`
    - Blog card grid layout (responsive)
    - Post page typography and image spacing
    - Pagination controls styling
    - _Requirements: 4.6, 4.7, 12.4_

- [x] 7. Portfolio Gallery and Project Pages
  - [x] 7.1 Create project collection entries with front matter
    - Generate/update `collections/_projects/` markdown files for all 23 projects
    - Front matter: title (from folder name, underscores → spaces, title case), date, image (glowne_* path), gallery array, description, tags
    - Handle missing glowne_* images with placeholder
    - _Requirements: 3.2, 3.8, 14.4, 14.5_

  - [x] 7.2 Create `collections/_pages/projects.html` portfolio grid page
    - CSS Grid layout: 1 col mobile, 2 col tablet (768px+), 3 col desktop (1024px+)
    - Project cards with featured image, overlay title on hover
    - `loading="lazy"` on images, explicit width/height
    - Staggered fade-up reveal on scroll (100–150ms per card)
    - _Requirements: 3.1, 3.3, 3.4, 3.9, 10.1_

  - [x] 7.3 Create `_layouts/project.html` individual project page
    - Vertical image gallery with 48px spacing desktop, 24px mobile
    - Click-to-lightbox on each image
    - Lazy loading on below-fold images, eager on first image
    - _Requirements: 3.5, 3.6, 3.7, 10.1, 10.2_

  - [x] 7.4 Create `_sass/_portfolio.scss`
    - Grid layout with `auto-fill` / `minmax()`
    - Card hover effect: scale(1.04) on image, title fade-in (300ms), `overflow: hidden`
    - Responsive breakpoints
    - Gap: 16px mobile, 24px tablet/desktop
    - _Requirements: 3.1, 3.3, 3.6, 9.3_

- [x] 8. Lightbox Component
  - [x] 8.1 Create `_includes/lightbox.html` and `assets/js/lightbox.js`
    - Full-screen overlay with `role="dialog"`, `aria-modal="true"`
    - Previous/Next buttons, close button (top-right)
    - Keyboard: Left/Right arrows, Escape to close
    - Touch: pointer events for swipe left/right
    - Focus trap while open
    - Fade-in open (300ms), crossfade between images (200ms)
    - Navigation controls only active while lightbox is open
    - _Requirements: 3.7, 8.1, 8.7_

  - [x] 8.2 Create `_sass/_lightbox.scss`
    - Full-screen overlay positioning
    - Image centering and max dimensions
    - Control button styling (close, prev, next)
    - Transition animations
    - _Requirements: 3.7_

- [x] 9. Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

- [x] 10. About Page
  - [x] 10.1 Create `collections/_pages/about.html`
    - Split layout: 7/12 image + 5/12 text on desktop (768px+)
    - Single column (image above text) on mobile
    - `images/personal/Iga_1.jpg` with descriptive alt (designer name)
    - Biographical content: name, studio founding, education, specializations
    - Scroll-triggered animations: image scale-in (900ms), text fade-up (800ms, staggered 100–150ms)
    - `prefers-reduced-motion`: content visible immediately
    - _Requirements: 5.1, 5.2, 5.3, 5.4, 5.5_

  - [x] 10.2 Create `_sass/_about.scss`
    - Split grid layout (7/12 + 5/12)
    - Responsive single-column below 768px
    - Image and text animation classes
    - _Requirements: 5.2, 5.3, 12.4_

- [x] 11. Offer Page
  - [x] 11.1 Create `collections/_pages/offer.html`
    - Service cards from `_data/services.yml` (responsive grid)
    - Process steps as numbered vertical timeline
    - CTA button linking to `/contact/`
    - Staggered reveal animation (total ≤ 1000ms, auto-adjust per-card delay)
    - Single-column below 768px
    - _Requirements: 6.1, 6.2, 6.3, 6.4, 6.5_

  - [x] 11.2 Create `_sass/_offer.scss`
    - Service cards grid layout
    - Timeline/process steps vertical layout
    - CTA button styling using accent color
    - Responsive breakpoints
    - _Requirements: 6.1, 6.2, 6.5, 12.4_

- [x] 12. Contact Page and Form Validation
  - [x] 12.1 Create `collections/_pages/contact.html` and `assets/js/contact.js`
    - Form fields: name (required, max 100), email (required, max 254), phone (optional, max 20), message (required, max 2000)
    - Client-side validation: required fields need ≥ 1 non-whitespace char, email regex `/\S+@\S+\.\S+/`
    - Inline error messages adjacent to invalid fields
    - Form action to Formspree or mailto fallback
    - Success: confirmation message in Polish, clear fields
    - Error: Polish error message, preserve field data
    - Display studio email + social links alongside form
    - _Requirements: 7.1, 7.2, 7.3, 7.4, 7.5, 7.6, 7.7_

  - [x] 12.2 Write property tests for required-field validation (fast-check)
    - **Property 7: Required Field Validation**
    - **Validates: Requirements 7.2**

  - [x] 12.3 Write property tests for email pattern validation (fast-check)
    - **Property 8: Email Pattern Validation**
    - **Validates: Requirements 7.3**

  - [x] 12.4 Create `_sass/_contact.scss`
    - Form layout and field styling
    - Validation error state styles (red border + message)
    - Success/error message styling
    - Responsive layout
    - _Requirements: 7.1, 7.7, 12.4_

- [x] 13. Animation Engine
  - [x] 13.1 Create `assets/js/scroll-animations.js`
    - Single Intersection Observer instance with threshold 0.15
    - Observe all `[data-animate]` elements
    - Animation classes: `fade-up`, `fade-in`, `scale-in` using only `transform` + `opacity`
    - Duration range: 150ms–1000ms
    - Deferred until after `DOMContentLoaded` + `si:page-ready` event
    - `prefers-reduced-motion`: elements start in final state, observer not initialized
    - _Requirements: 8.1, 8.2, 8.3, 8.4, 8.7_

  - [x] 13.2 Create `_sass/_animations.scss`
    - Animation keyframes and utility classes for `fade-up`, `fade-in`, `scale-in`
    - Initial hidden states for `[data-animate]` elements
    - `.is-visible` class with final states
    - `prefers-reduced-motion` media query: all elements in final state
    - Duration/easing using CSS custom properties
    - _Requirements: 8.1, 8.5, 8.7_

- [x] 14. Footer and Global Elements
  - [x] 14.1 Create `_includes/footer.html` and `_sass/_footer.scss`
    - Navigation links (Home, Projekty, O Mnie, Oferta, Kontakt)
    - Social media links (Facebook, Instagram) with `target="_blank"`, `rel="noopener"`, accessible labels
    - Copyright: "2024 © Si-Studio"
    - Back-to-top button (visible after scrolling 1 viewport height, smooth scroll to top)
    - _Requirements: 13.1, 13.2, 13.3, 13.4, 13.5_

- [x] 15. SEO and Structured Data
  - [x] 15.1 Create `_includes/seo.html` with JSON-LD and meta
    - LocalBusiness schema on homepage (name: "Si Studio", address: Szczecin, url, telephone)
    - Per-page Open Graph tags (og:title, og:description, og:image, og:url)
    - Canonical URL on all pages
    - Unique meta descriptions from front matter (50–160 chars)
    - _Requirements: 15.1, 15.2, 15.4, 15.5_

  - [x] 15.2 Create custom `404.html` page
    - Uses `default` layout (includes header, footer, navigation)
    - Polish-language message
    - Link back to homepage
    - _Requirements: 14.6_

- [x] 16. Image Optimization and Performance
  - [x] 16.1 Implement image loading strategy across all templates
    - Hero + above-fold images: `loading="eager"` (no lazy)
    - Below-fold images: `loading="lazy"`
    - All images: explicit `width` and `height` attributes for CLS prevention
    - Placeholder backgrounds using palette colors on all image containers
    - Error handling: continue showing placeholder + alt text on failed loads
    - _Requirements: 10.1, 10.2, 10.3, 10.4, 10.5, 10.6_

  - [x] 16.2 Add responsive image `srcset` attributes
    - Define srcset for project images at appropriate breakpoints
    - Ensure LCP target < 2500ms for hero image
    - _Requirements: 9.6, 10.6_

- [x] 17. GitHub Actions Pipeline Update
  - [x] 17.1 Update `.github/workflows/jekyll.yml` to run pre-build script
    - Add step to run `ruby scripts/generate-posts.rb` before `jekyll build`
    - Ensure `_posts` directory is created with generated content
    - Verify build completes with zero errors
    - _Requirements: 14.9_

- [x] 18. Responsive Layout Polish
  - [x] 18.1 Verify and fix responsive behavior across all pages
    - Test at 375px, 768px, 1024px, 1400px breakpoints
    - Ensure no horizontal scrolling on any viewport
    - Verify max-width 1400px centering on large screens
    - Touch targets minimum 44×44px on mobile
    - Content sections: 24px spacing mobile, 48px spacing desktop
    - _Requirements: 9.1, 9.2, 9.3, 9.4, 9.5, 12.4_

- [x] 19. Final Checkpoint - Ensure all tests pass
  - Ensure all tests pass, ask the user if questions arise.

## Notes

- Tasks marked with `*` are optional and can be skipped for faster MVP
- Each task references specific requirements for traceability
- Checkpoints ensure incremental validation
- Property tests validate universal correctness properties (Properties 1–6 in Ruby/rantly, Properties 7–8 in JavaScript/fast-check)
- Unit tests validate specific examples and edge cases
- The build script (task 6.1) is critical path — blog content depends on it
- All content is in Polish; use Polish for UI text, error messages, and meta descriptions
- Only existing repository assets are used — no new images created

## Task Dependency Graph

```json
{
  "waves": [
    { "id": 0, "tasks": ["1.1", "1.2", "1.3"] },
    { "id": 1, "tasks": ["1.4", "1.5"] },
    { "id": 2, "tasks": ["2.1", "2.2", "3.1", "3.2", "4.1"] },
    { "id": 3, "tasks": ["2.3", "4.2", "6.1"] },
    { "id": 4, "tasks": ["6.2", "6.3", "6.4", "6.5", "6.6", "6.7", "6.8", "6.9", "7.1"] },
    { "id": 5, "tasks": ["7.2", "7.3", "7.4", "8.1", "8.2"] },
    { "id": 6, "tasks": ["10.1", "10.2", "11.1", "11.2", "12.1"] },
    { "id": 7, "tasks": ["12.2", "12.3", "12.4", "13.1", "13.2"] },
    { "id": 8, "tasks": ["14.1", "15.1", "15.2"] },
    { "id": 9, "tasks": ["16.1", "16.2", "17.1"] },
    { "id": 10, "tasks": ["18.1"] }
  ]
}
```
