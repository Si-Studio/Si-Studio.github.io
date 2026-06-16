# frozen_string_literal: true

require 'spec_helper'
require 'rantly'
require 'rantly/rspec_extensions'
require 'si_studio/post_generator'

# Feature: premium-interior-design-website, Property 2: Blog Post Generation from Instagram Content
# **Validates: Requirements 4.1**
#
# For any .txt file in sistudio_content with a valid YYYYMMDD_SHORTCODE filename prefix,
# the generation script SHALL produce a Jekyll post file with: a date field matching
# the parsed date, a title field extracted from the text content, an image field
# pointing to either the corresponding .jpg file or the default placeholder, and body
# content matching the full .txt file content.

RSpec.describe SiStudio::PostGenerator, '.generate_post_data' do
  describe 'Property 2: Blog Post Generation from Instagram Content' do
    it 'produces a post with correct date, title, image, and body for any valid input' do
      property_of {
        # Generate a valid date prefix (YYYYMMDD)
        year = range(2020, 2030)
        month = range(1, 12)
        max_day = case month
                  when 2 then 28
                  when 4, 6, 9, 11 then 30
                  else 31
                  end
        day = range(1, max_day)
        date_prefix = format('%04d%02d%02d', year, month, day)

        # Generate Instagram-style shortcode (alphanumeric, 6-11 chars)
        len = range(6, 11)
        shortcode = Array.new(len) {
          freq([5, :call, proc { Rantly.new.choose(*('a'..'z').to_a) }],
               [5, :call, proc { Rantly.new.choose(*('A'..'Z').to_a) }],
               [3, :call, proc { Rantly.new.choose(*('0'..'9').to_a) }])
        }.join

        stem = "#{date_prefix}_#{shortcode}"

        # Generate text content (4 variants)
        variant = range(0, 3)
        text = case variant
               when 0
                 # Short text with a period
                 word_count = range(3, 15)
                 words = Array.new(word_count) {
                   wlen = range(2, 10)
                   Array.new(wlen) { Rantly.new.choose(*('a'..'z').to_a) }.join
                 }
                 words.join(' ') + '.'
               when 1
                 # Text with newline
                 line1 = Array.new(range(2, 10)) {
                   wlen = range(2, 8)
                   Array.new(wlen) { Rantly.new.choose(*('a'..'z').to_a) }.join
                 }.join(' ')
                 line2 = Array.new(range(2, 10)) {
                   wlen = range(2, 8)
                   Array.new(wlen) { Rantly.new.choose(*('a'..'z').to_a) }.join
                 }.join(' ')
                 "#{line1}\n#{line2}"
               when 2
                 # Long text without period or newline (triggers truncation)
                 words = Array.new(range(20, 40)) {
                   wlen = range(3, 8)
                   Array.new(wlen) { Rantly.new.choose(*('a'..'z').to_a) }.join
                 }
                 words.join(' ')
               when 3
                 # Empty text
                 ''
               end

        # Randomly decide if corresponding jpg exists
        has_jpg = freq([7, :literal, true], [3, :literal, false])

        available_jpgs = if has_jpg
                          jpgs = ["#{stem}.jpg"]
                          extra_count = range(0, 3)
                          extra_count.times { |i| jpgs << "#{stem}_#{i + 1}.jpg" }
                          jpgs
                        else
                          []
                        end

        [stem, text, available_jpgs, has_jpg]
      }.check(100) { |stem, text, available_jpgs, has_jpg|
        result = SiStudio::PostGenerator.generate_post_data(stem, text, available_jpgs)

        # The result should not be nil for valid stems
        expect(result).not_to be_nil,
          "Expected non-nil result for stem '#{stem}'"

        # Property: date field matches the parsed date (YYYYMMDD → YYYY-MM-DD)
        parsed = SiStudio::PostGenerator.parse_filename(stem)
        year, month, day, _shortcode = parsed
        expected_date = "#{year}-#{month}-#{day}"
        expect(result[:date]).to eq(expected_date),
          "Expected date '#{expected_date}', got '#{result[:date]}' (stem: '#{stem}')"

        # Property: title is non-empty (or "Bez tytułu" for empty text)
        expected_title = SiStudio::PostGenerator.extract_title(text)
        expect(result[:title]).to eq(expected_title),
          "Expected title '#{expected_title}', got '#{result[:title]}'"
        expect(result[:title]).not_to be_empty,
          "Title should never be empty"

        # Property: image field is either the matching jpg path or the placeholder
        if has_jpg
          expect(result[:image]).to start_with('/images/blog/'),
            "Expected image to start with '/images/blog/', got '#{result[:image]}'"
          img_filename = result[:image].sub('/images/blog/', '')
          expect(available_jpgs).to include(img_filename),
            "Expected image '#{img_filename}' to be in available jpgs #{available_jpgs}"
        else
          expect(result[:image]).to eq(SiStudio::PostGenerator::PLACEHOLDER_IMAGE),
            "Expected placeholder '#{SiStudio::PostGenerator::PLACEHOLDER_IMAGE}', got '#{result[:image]}'"
        end

        # Property: body content matches the full original text content
        expect(result[:body]).to eq(text),
          "Expected body to match input text"
      }
    end
  end
end
