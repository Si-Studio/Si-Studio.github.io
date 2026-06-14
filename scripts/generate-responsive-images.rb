#!/usr/bin/env ruby
# frozen_string_literal: true

# generate-responsive-images.rb
# Pre-build script: generates resized image variants for responsive srcset.
# Requires ImageMagick (`convert` command) to be available.
# Run from project root before `jekyll build`.
#
# For each project image, generates:
#   - 400w (mobile)
#   - 800w (tablet)
#   - 1200w (desktop)
# Original is preserved as the full-size fallback.
#
# Output: images/responsive/ directory with resized copies.
# Naming: original-400w.jpg, original-800w.jpg, original-1200w.jpg

require 'fileutils'

PROJECTS_DIR = File.join(__dir__, '..', 'images', 'projects')
OUTPUT_DIR = File.join(__dir__, '..', 'images', 'responsive')
WIDTHS = [400, 800, 1200]

# Check if ImageMagick is available
def imagemagick_available?
  system('which convert > /dev/null 2>&1')
end

def resize_image(input_path, output_path, width)
  # Use ImageMagick convert with quality optimization
  system("convert '#{input_path}' -resize #{width}x -quality 82 -strip '#{output_path}'")
end

def process_project(project_dir)
  project_name = File.basename(project_dir)
  output_project_dir = File.join(OUTPUT_DIR, project_name)
  FileUtils.mkdir_p(output_project_dir)

  images = Dir.glob(File.join(project_dir, '*.{jpg,jpeg,png}'))
  processed = 0

  images.each do |img_path|
    basename = File.basename(img_path, File.extname(img_path))
    ext = File.extname(img_path)

    WIDTHS.each do |width|
      output_filename = "#{basename}-#{width}w#{ext}"
      output_path = File.join(output_project_dir, output_filename)

      # Skip if already generated (incremental)
      next if File.exist?(output_path)

      if resize_image(img_path, output_path, width)
        processed += 1
      end
    end
  end

  processed
end

def main
  unless imagemagick_available?
    warn "WARNING: ImageMagick not found. Skipping responsive image generation."
    warn "Install with: sudo apt install imagemagick (Ubuntu) or brew install imagemagick (macOS)"
    puts "Skipped responsive image generation (ImageMagick not available)"
    return
  end

  FileUtils.mkdir_p(OUTPUT_DIR)

  project_dirs = Dir.glob(File.join(PROJECTS_DIR, '*')).select { |f| File.directory?(f) }
  total_processed = 0

  project_dirs.each do |dir|
    total_processed += process_project(dir)
  end

  puts "Generated #{total_processed} responsive image variants across #{project_dirs.length} projects"
end

main
