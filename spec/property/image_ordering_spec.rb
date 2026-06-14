# frozen_string_literal: true

# Feature: premium-interior-design-website, Property 5: Image Suffix Numerical Ordering
# Validates: Requirements 4.5

require 'spec_helper'

RSpec.describe 'Property 5: Image Suffix Numerical Ordering' do
  # Generator: produces a random stem and a shuffled set of numeric suffixes
  def generate_image_set(rantly)
    # Random date component: YYYYMMDD
    year = rantly.range(2020, 2030)
    month = rantly.range(1, 12).to_s.rjust(2, '0')
    day = rantly.range(1, 28).to_s.rjust(2, '0')

    # Random shortcode: 8-12 alphanumeric characters
    shortcode_length = rantly.range(8, 12)
    shortcode = (1..shortcode_length).map { rantly.choose('A'..'Z', 'a'..'z', '0'..'9') }.join

    stem = "#{year}#{month}#{day}_#{shortcode}"

    # Generate a random set of unique numeric suffixes (at least 2, up to 20)
    suffix_count = rantly.range(2, 20)
    suffixes = (1..100).to_a.sample(suffix_count).sort_by { rand }

    # Build filenames from suffixes, then shuffle
    filenames = suffixes.map { |n| "#{stem}_#{n}.jpg" }.shuffle

    { stem: stem, suffixes: suffixes, filenames: filenames }
  end

  it 'sorts images by ascending numeric suffix, not lexicographic order' do
    property_of {
      # Random date component
      year = range(2020, 2030)
      month = range(1, 12).to_s.rjust(2, '0')
      day = range(1, 28).to_s.rjust(2, '0')

      # Random shortcode
      shortcode_length = range(8, 12)
      shortcode = (1..shortcode_length).map { choose(*('A'..'Z').to_a, *('a'..'z').to_a, *('0'..'9').to_a) }.join

      stem = "#{year}#{month}#{day}_#{shortcode}"

      # Generate unique numeric suffixes (2 to 20 items)
      suffix_count = range(2, 20)
      all_possible = (1..100).to_a
      suffixes = all_possible.sample(suffix_count)

      # Build shuffled filenames
      filenames = suffixes.map { |n| "#{stem}_#{n}.jpg" }.shuffle

      [stem, suffixes, filenames]
    }.check(100) { |stem, suffixes, filenames|
      sorted = SiStudio::ImageSorter.sort_images(filenames, stem)

      # Extract suffix numbers from sorted result
      sorted_suffixes = sorted.map do |img|
        File.basename(img, '.jpg').delete_prefix("#{stem}_").to_i
      end

      # Property 1: Each suffix is strictly greater than the previous (ascending numerical order)
      sorted_suffixes.each_cons(2) do |a, b|
        expect(b).to be > a,
          "Expected ascending order but got #{a} before #{b} in #{sorted_suffixes.inspect}"
      end

      # Property 2: Numerical sort, not lexicographic (_2 before _10)
      # This is implicitly tested by strict ascending, but let's be explicit:
      # If we had [2, 10] in input, lexicographic would put 10 before 2
      # Our ascending check already catches this.

      # Property 3: All input images are present in output (no loss)
      expect(sorted.sort).to eq(filenames.sort)

      # Property 4: Output length equals input length
      expect(sorted.length).to eq(filenames.length)
    }
  end
end
