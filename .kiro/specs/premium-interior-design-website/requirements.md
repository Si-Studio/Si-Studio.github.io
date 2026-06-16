# Requirements Document

## Introduction

Si Studio is a premium interior design studio run by Iga Śmierzchalska, based in Szczecin, Poland. This project involves building a complete $10,000-grade website from scratch using Jekyll and hosted on GitHub Pages. The website must convey the same level of sophistication and elegance found at top London interior design firms (Henri Fitzwilliam Lay, London Design Group, Bryan O'Sullivan, Taylor Howes, Bernard London, Sims Hilditch). The site uses only existing repository assets: 23 project portfolios with interior photography, personal designer photos, logo assets, and 100+ Instagram posts (with images and Polish-language captions) from the sistudio_content folder. All content is in Polish. Animations must be elegant and performant across all devices.

## Glossary

- **Website**: The complete Jekyll-based static site for Si Studio, deployed to GitHub Pages
- **Hero_Section**: The full-viewport opening section of the homepage featuring dramatic imagery and minimal text
- **Portfolio_Gallery**: The projects showcase section displaying interior design work organized by project
- **Blog_Engine**: The Jekyll-powered blog section sourcing content from sistudio_content Instagram data
- **Navigation_System**: The site-wide menu including desktop and mobile variations
- **Animation_Engine**: The JavaScript-based system responsible for scroll-triggered reveals, parallax, and micro-interactions
- **Contact_Form**: The page enabling visitors to submit design inquiries
- **About_Section**: The designer biography page featuring personal information and philosophy
- **Offer_Section**: The services/pricing page describing available design packages
- **Image_Optimizer**: The build-time or lazy-loading system ensuring images load performantly
- **Responsive_Layout**: The CSS system adapting the design across mobile, tablet, and desktop viewports
- **Instagram_Content**: The collection of posts (images and text captions) stored in sistudio_content folder
- **Project_Entry**: A single interior design project containing a featured image and gallery images

## Requirements

### Requirement 1: Homepage Hero Experience

**User Story:** As a potential client, I want to be immediately captivated by a full-screen hero section with cinematic imagery, so that I perceive Si Studio as a premium, high-end design firm.

#### Acceptance Criteria

1. WHEN the homepage loads, THE Hero_Section SHALL display a full-viewport background image from the existing project photography with a minimum height of 100vh
2. WHEN the homepage loads, THE Hero_Section SHALL overlay the studio name and a tagline (maximum 80 characters) in a serif typeface, rendered over a semi-transparent dark overlay or gradient to ensure a minimum contrast ratio of 4.5:1 against the background image per WCAG 2.1 AA
3. WHEN the user scrolls past the Hero_Section, THE Animation_Engine SHALL apply a parallax effect to the background image at a rate between 0.3x and 0.5x scroll speed
4. THE Hero_Section SHALL include a single scroll-indicator element positioned at the bottom center of the viewport that plays a continuous vertical bounce animation with a cycle duration between 1500ms and 2500ms
5. WHEN the page finishes loading, THE Hero_Section SHALL reveal text elements with a staggered fade-in animation completing within 1200ms total
6. IF the hero background image triggers an explicit load error event, THEN THE Hero_Section SHALL display a solid background color from the site's warm neutral palette while keeping the text overlay visible and readable

### Requirement 2: Site-Wide Navigation

**User Story:** As a visitor, I want elegant and accessible navigation, so that I can move between pages without disrupting the premium aesthetic.

#### Acceptance Criteria

1. THE Navigation_System SHALL display the Si Studio logo and links to Home, Projekty, O Mnie, Blog, Oferta, and Kontakt pages
2. WHILE the page scroll position is 80px or less from the top, THE Navigation_System SHALL display with a fully transparent background
3. WHEN the user scrolls down past 80px, THE Navigation_System SHALL transition to an opaque background with a backdrop blur of 8px, completing the transition within 300ms
4. WHILE the viewport width is below 768px, THE Navigation_System SHALL collapse menu items into a hamburger button with an aria-expanded attribute reflecting the menu state
5. WHEN the hamburger button is activated on mobile (viewport below 768px only), THE Navigation_System SHALL reveal a full-screen overlay menu with links appearing in staggered sequence (50–100ms delay per item) completing all animations within 600ms
6. THE Navigation_System SHALL remain fixed at the top of the viewport on all pages
7. THE Navigation_System SHALL indicate the current active page by applying a visually distinct style (such as a different color, underline, or font weight) to the corresponding link that is distinguishable from inactive links without relying on color alone
8. WHEN the mobile overlay menu is open, THE Navigation_System SHALL trap keyboard focus within the menu and close the menu when the Escape key is pressed, returning focus to the hamburger button
9. IF the user has enabled prefers-reduced-motion, THEN THE Navigation_System SHALL disable staggered link animations and background transitions, applying state changes instantly

### Requirement 3: Portfolio Projects Showcase

**User Story:** As a potential client, I want to browse beautifully presented interior design projects, so that I can evaluate the studio's design quality and style range.

#### Acceptance Criteria

1. WHEN the projects page loads, THE Portfolio_Gallery SHALL display all 23 available projects as a grid layout with a minimum of 2 columns on tablet (768px+) and 3 columns on desktop (1024px+), using each project's featured (glowne) image
2. THE Portfolio_Gallery SHALL display each project card with the project name derived from the folder name by replacing underscores with spaces and applying title-case capitalization in Polish
3. WHEN the user hovers over a project card on desktop, THE Animation_Engine SHALL apply a scale transform between 1.03x and 1.05x on the image and reveal the project title with a fade transition completing within 300ms
4. WHEN the user taps a project card on a touch device, THE Website SHALL navigate to the dedicated project page without requiring a hover interaction
5. WHEN the user clicks a project card, THE Website SHALL navigate to a dedicated project page showing all images from that project's folder in a vertical gallery layout
6. WHEN a project page loads, THE Website SHALL display images in a vertical scroll layout with a minimum spacing of 48px between images on desktop and 24px on mobile (below 768px)
7. WHEN the user clicks an image in the project gallery, THE Website SHALL open a full-screen lightbox with previous/next button navigation, keyboard arrow-key navigation, and touch swipe navigation between images; lightbox navigation controls SHALL only be active while the lightbox is open
8. IF a project has no featured (glowne) image, THEN THE Portfolio_Gallery SHALL display a placeholder background matching the site's color palette in place of the missing image
9. WHEN the projects page loads, THE Animation_Engine SHALL reveal project cards with a staggered scroll-triggered fade-up animation using a per-card delay of 100ms to 150ms as they enter the viewport

### Requirement 4: Blog Section from Instagram Content

**User Story:** As a visitor, I want to read interior design insights and project stories, so that I can learn about the designer's process and expertise.

#### Acceptance Criteria

1. THE Blog_Engine SHALL generate blog posts from the sistudio_content folder, using .txt files as post body content and .jpg files with the same filename prefix (excluding numbered suffixes) as featured images
2. WHEN the blog index page loads, THE Blog_Engine SHALL display posts in reverse chronological order based on the date prefix in filenames (format: YYYYMMDD), with the publication date displayed in DD.MM.YYYY format
3. THE Blog_Engine SHALL display each blog post card with the featured image, a title extracted from the .txt content up to the first period or newline character (truncated at 80 characters with an ellipsis if exceeded), and the publication date
4. WHEN the user clicks a blog post card, THE Website SHALL navigate to a full blog post page displaying the complete text content and all images whose filename shares the same date prefix as the post
5. WHERE a post has multiple images (numbered suffixes _1, _2, _3), THE Blog_Engine SHALL display all images in the individual post view as a vertically stacked scrollable gallery in numerical suffix order
6. THE Blog_Engine SHALL display a maximum of 12 posts per page on the blog index, and IF the total number of posts exceeds 12, THEN THE Blog_Engine SHALL display next/previous pagination controls to navigate between pages; IF a pagination page would display zero posts, THEN THE Blog_Engine SHALL redirect to the last page containing content
7. WHEN the blog index page loads, THE Animation_Engine SHALL reveal post cards with a scroll-triggered fade-up animation as each card enters the viewport, completing within 600ms per card
8. IF a .txt file in sistudio_content has no corresponding .jpg file, THEN THE Blog_Engine SHALL generate the blog post using a site-default placeholder image as the featured image

### Requirement 5: About the Designer Page

**User Story:** As a potential client, I want to learn about the designer behind Si Studio, so that I can build trust and understand the studio's design philosophy.

#### Acceptance Criteria

1. WHEN the about page loads, THE About_Section SHALL display the designer's personal photograph (Iga_1.jpg or Iga_2.jpg from images/personal/) with a descriptive alt attribute identifying the designer by name, alongside biographical text that includes the designer's name, studio founding context, educational background, and design specializations
2. WHILE the viewport width is 768px or above, THE About_Section SHALL present content in a split-layout with the image occupying approximately 7/12 of the grid width on one side and the text occupying the remaining 5/12 on the other side
3. WHEN the viewport width is below 768px, THE About_Section SHALL stack the image above the text content in a single-column layout
4. WHEN the about page content area scrolls into the viewport (top of element crosses 85% of viewport height), THE Animation_Engine SHALL reveal the image with a scale-in animation (duration 900ms) and text blocks with sequential fade-up animations (duration 800ms each, staggered with 100-150ms delays between elements), both easing with a deceleration curve
5. IF the user has enabled prefers-reduced-motion, THEN THE Animation_Engine SHALL skip all scroll-triggered animations and display content in its final visible state immediately

### Requirement 6: Services/Offer Page

**User Story:** As a potential client, I want to understand the available design services and process, so that I can determine which service fits my needs.

#### Acceptance Criteria

1. WHEN the offer page loads, THE Offer_Section SHALL display between 2 and 6 design service categories, each presented as a distinct card or section containing a service name and a description of at least 20 characters
2. THE Offer_Section SHALL present the design process as 3 to 7 numbered sequential steps, each with a step number or progress indicator and a label describing the phase
3. WHEN service cards scroll into view, THE Animation_Engine SHALL apply a staggered reveal animation with a total animation duration not exceeding 1000ms for all visible cards, automatically reducing per-card stagger delays when the number of cards would otherwise exceed the 1000ms limit
4. THE Offer_Section SHALL include a call-to-action element styled as a button or prominent link that navigates the user to the contact page when activated
5. WHEN the viewport width is below 768px, THE Offer_Section SHALL stack service cards and process steps in a single-column vertical layout

### Requirement 7: Contact Page

**User Story:** As a potential client, I want to easily submit a design inquiry, so that I can initiate a conversation about my project.

#### Acceptance Criteria

1. THE Contact_Form SHALL display fields for name (maximum 100 characters), email (maximum 254 characters), phone number (optional, maximum 20 characters), and message (maximum 2000 characters)
2. WHEN the user submits the form, THE Contact_Form SHALL validate that name, email, and message fields each contain at least 1 non-whitespace character and reject submission if any required field is empty
3. WHEN the email field contains a value that does not match the pattern [non-whitespace]@[non-whitespace].[non-whitespace], THE Contact_Form SHALL display an inline validation error message adjacent to the email field indicating the expected format
4. THE Contact_Form SHALL display the studio's contact email address and social media profile links alongside the form
5. WHEN the form is submitted successfully, THE Contact_Form SHALL display a confirmation message indicating the inquiry was received, and clear all form fields
6. IF the form submission fails due to a network or server error, or IF the submission status is ambiguous (timeout or connection lost), THEN THE Contact_Form SHALL display an error message indicating submission was unsuccessful without exposing technical details, and SHALL preserve the user's entered data in all form fields
7. THE Contact_Form SHALL use the same typographic scale, color palette, and spacing tokens defined in the site-wide design system

### Requirement 8: Performance-Focused Animations

**User Story:** As a visitor on any device, I want smooth animations that enhance the browsing experience, so that the site feels premium without sacrificing loading speed.

#### Acceptance Criteria

1. THE Animation_Engine SHALL use CSS transforms and opacity exclusively for animations to ensure GPU-accelerated rendering
2. THE Animation_Engine SHALL implement scroll-triggered reveal animations using the Intersection Observer API, triggering each animation when the target element enters at least 15% of the viewport height
3. IF the user has prefers-reduced-motion enabled, THEN THE Animation_Engine SHALL disable all animations and transitions except content opacity (fade-in to full visibility without motion)
4. THE Animation_Engine SHALL defer animation initialization until after the DOMContentLoaded event has fired and any page-loader sequence has completed
5. WHILE animations are running, THE Animation_Engine SHALL maintain a frame rate of at least 60fps as measured on a device with a mid-range mobile processor (equivalent to Snapdragon 600 series or higher)
6. WHILE images are loading, THE Website SHALL display placeholder states using a solid CSS background color from the site's defined palette, matching the dominant tone of the image section, with no layout shift when the image renders
7. THE Animation_Engine SHALL limit animation durations to between 150ms and 1000ms per individual animation sequence

### Requirement 9: Responsive Design and Mobile Experience

**User Story:** As a mobile visitor, I want the website to be fully functional and beautiful on my device, so that I can browse the portfolio and contact the studio from anywhere.

#### Acceptance Criteria

1. THE Responsive_Layout SHALL adapt seamlessly across viewports at breakpoints of 375px (mobile), 768px (tablet), and 1024px (desktop minimum)
2. THE Responsive_Layout SHALL use a maximum content width of 1400px with centered alignment on all screens where the viewport exceeds 1400px
3. WHEN the viewport is below 768px, THE Portfolio_Gallery SHALL switch from a multi-column layout to a single-column layout
4. THE Website SHALL prevent horizontal scrolling on all viewport sizes
5. THE Responsive_Layout SHALL apply appropriate touch targets of minimum 44px by 44px for all interactive elements on mobile
6. THE Website SHALL use responsive image sizing with srcset attributes to serve appropriately sized images based on viewport width

### Requirement 10: Image Loading and Optimization

**User Story:** As a visitor, I want images to load quickly and progressively, so that I can start viewing content without long wait times.

#### Acceptance Criteria

1. THE Image_Optimizer SHALL implement native lazy loading (loading="lazy") for all images positioned below the initial viewport fold, where the fold is defined as the first 900px of vertical content on viewports 1024px wide or larger, and the first 700px on viewports below 1024px
2. THE Image_Optimizer SHALL ensure the hero image and above-fold images load eagerly (loading="eager" or no loading attribute) without lazy loading delay
3. THE Website SHALL specify explicit width and height attributes or aspect-ratio CSS on all image containers such that cumulative layout shift (CLS) attributable to images remains below 0.1 as measured by Lighthouse
4. WHEN an image has not yet loaded, THE Website SHALL display a solid or tinted placeholder using a background color from the site's defined color palette, sized to match the declared dimensions of the image container
5. IF an image fails to load permanently (network error or 4xx/5xx response), THEN THE Website SHALL continue displaying the placeholder background and render an alt-text fallback, without triggering additional layout shift
6. THE Website SHALL achieve a Largest Contentful Paint (LCP) time of under 2500ms when tested using Lighthouse with simulated throttling (4G profile: 1.6 Mbps download, 750 Kbps upload, 150ms RTT)

### Requirement 11: Typography and Visual Identity

**User Story:** As a brand-conscious studio owner, I want the website typography to reflect premium interior design aesthetics, so that the site communicates quality and taste instantly.

#### Acceptance Criteria

1. THE Website SHALL use a serif display typeface for headings and a sans-serif typeface for body text, both loaded via Google Fonts, with a system font fallback stack specified for each (serif fallback for headings, sans-serif fallback for body)
2. THE Website SHALL limit font weight loading to a maximum of 3 weights per typeface to minimize load time
3. THE Website SHALL maintain a consistent typographic scale across all pages using a modular scale with a ratio between 1.2 and 1.333, where each heading level (h1 through h4) corresponds to a defined step on the scale
4. THE Website SHALL ensure body text has a minimum font size of 16px and a line height between 1.5 and 1.7 for readability
5. THE Website SHALL use font-display: swap for all custom fonts to prevent invisible text during loading
6. THE Website SHALL apply the display typeface exclusively to heading elements (h1–h4) and the body typeface to all paragraph, list, and UI text, with no mixing of typeface roles within a single page

### Requirement 12: Color Palette and Visual Atmosphere

**User Story:** As a visitor, I want the site to feel calm, sophisticated, and warm, so that it evokes the quality of the interior design work showcased.

#### Acceptance Criteria

1. THE Website SHALL use a color palette of no more than 5 distinct colors total: up to 4 warm neutral tones (cream, warm white, soft taupe) for backgrounds, text, and borders, plus exactly 1 accent color reserved for interactive elements
2. THE Website SHALL maintain a minimum contrast ratio of 4.5:1 for body text and 3:1 for large text per WCAG 2.1 AA standards
3. THE Website SHALL use only colors defined in the palette across all pages, including backgrounds, text, borders, and interactive states (hover, focus, active, and disabled)
4. THE Website SHALL apply minimum spacing of 24px between content sections on viewports below 768px and minimum spacing of 48px between content sections on viewports 768px and above
5. IF any page element uses a color not defined in the palette, THEN THE Website SHALL be considered non-compliant with the color palette requirement

### Requirement 13: Footer and Global Elements

**User Story:** As a visitor, I want to access key information and social links from any page, so that I can easily find contact details and follow the studio's work.

#### Acceptance Criteria

1. THE Website SHALL display a footer on all pages containing navigation links (Home, Projekty, O Mnie, Oferta, Kontakt), social media links (Facebook, Instagram), and copyright notice
2. THE Website SHALL display social media icons in the footer as clickable elements linking to the studio's Facebook and Instagram profiles, where each link opens in a new browser tab and includes an accessible label identifying the platform name
3. WHEN a visitor activates the "back to top" control, THE Website SHALL smoothly scroll the viewport to the top of the page
4. THE Website SHALL display the copyright text "2024 © Si-Studio" in the footer
5. WHILE the visitor has scrolled beyond one viewport height, THE Website SHALL display the "back to top" control in a fixed position visible above the footer area

### Requirement 14: Jekyll Architecture and GitHub Pages Compatibility

**User Story:** As a developer, I want the site built with clean Jekyll architecture, so that it deploys correctly on GitHub Pages and remains maintainable.

#### Acceptance Criteria

1. THE Website SHALL use Jekyll 4.x with a `_layouts` directory containing at least one base layout, an `_includes` directory for reusable partials, and a `_data` directory for structured YAML data files
2. THE Website SHALL generate a sitemap.xml via the jekyll-sitemap plugin that contains URL entries for all pages, posts, and project collection documents with `output: true`
3. THE Website SHALL compile all CSS from source files during the Jekyll build or the GitHub Actions CI pipeline without requiring the developer to run separate manual build steps locally before committing
4. THE Website SHALL organize project content using a Jekyll collection named `projects` with `output: true` and a defined permalink pattern, stored under the configured `collections_dir`
5. THE Website SHALL use Jekyll front matter on every page and collection document to define, at minimum, `title` and `image`; posts SHALL additionally include `date` and `tags`
6. IF a requested page does not exist, THEN THE Website SHALL display a custom 404.html page that uses the site's base layout, includes the site header and footer, and provides at least one navigation link back to an existing page; THE Website SHALL allow the build to succeed even if 404.html is missing, falling back to server default error pages
7. THE Website SHALL include the site header, footer, and Navigation_System on all pages regardless of content type
8. THE Website SHALL structure blog posts as files within the `_posts` collection directory using the Jekyll `YYYY-MM-DD-title.md` filename convention, with front matter containing `title`, `date`, `image`, and `tags` fields
9. WHEN the GitHub Actions workflow executes `bundle exec jekyll build`, THEN THE Website SHALL complete the build with zero errors and produce a `_site` directory containing all expected output pages

### Requirement 15: SEO and Meta Information

**User Story:** As a studio owner, I want the website to be discoverable by search engines, so that potential clients can find Si Studio online.

#### Acceptance Criteria

1. THE Website SHALL include Open Graph meta tags on all pages with og:title, og:description, og:image, and og:url properties
2. THE Website SHALL generate unique meta descriptions for each project page and blog post, with a length between 50 and 160 characters
3. THE Website SHALL use semantic HTML5 elements (header, nav, main, article, section, footer) throughout all templates
4. THE Website SHALL implement structured data (JSON-LD) for the LocalBusiness schema on the homepage including name, address, url, and telephone fields
5. THE Website SHALL include a canonical URL meta tag on all pages using the page's absolute URL

### Requirement 16: Page Loading Experience

**User Story:** As a visitor, I want an elegant loading experience, so that I perceive the site as polished from the first moment.

#### Acceptance Criteria

1. WHEN the page is loading, THE Website SHALL display a loading indicator featuring the Si Studio logo with a fade-in and upward-slide reveal animation
2. WHEN the page content has loaded (DOMContentLoaded or equivalent), THE Website SHALL begin fading out the loading indicator and sliding it off-screen, then reveal the page content, completing the full transition sequence within 2100ms without waiting for all resources to finish loading
3. IF the loading indicator has not completed its animation within 3000ms, THEN THE Website SHALL force-hide the loading indicator and reveal the page content immediately
4. THE Website SHALL ensure the loading indicator markup and inline styles total under 5KB excluding any shared animation library already loaded by the page
5. WHILE navigating between pages, THE Website SHALL apply a page transition effect with a duration between 300ms and 800ms
6. IF the user has enabled prefers-reduced-motion, THEN THE Website SHALL skip all loading and transition animations but allow the normal loading flow to complete before displaying page content
