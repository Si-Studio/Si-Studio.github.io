# frozen_string_literal: true

# Feature: premium-interior-design-website, Property 5: Image Suffix Numerical Ordering
# Validates: Requirements 4.5

require 'spec_helper'

RSpec.describe 'Property 5: Image Suffix Numerical Ordering' do
  it 'sorts images in ascending numerical suffix order, not lexicographic' do
    property_of {
      # Generate a random stem: YYYYMMDD_SHORTCODE
      year = range(2020, 2030)
      month = range(1, 12).to_s.rjust(2, '0')
      day = range(1, 28).to_s.rjust(2, '0')

      shortcode_length = range(8, 12)
      shortcode = (1..shortcode_length).map {
        choose(*('A'..'Z').to_a, *('a'..'z').to_a, *('0'..'9').to_a)
      }.join

      stem = "#{year}#{month}#{day}_#{shortcode}"

      # Generate 2-20 unique numeric suffixes from 1..100 (shuffled)
      suffix_count = range(2, 20)
      suffixes = (1..100).to_a.sample(suffix_count)
      filenames = suffixes.map { |n| "#{stem}_#{n}.jpg" }.shuffle

      [stem, filenames]
    }.check(100) { |stem, filenames|
      sorted = SiStudio::ImageSorter.sort_images(filenames, stem)

      # Extract numeric suffixes from sorted result
      sorted_suffixes = sorted.map do |img|
        File.basename(img, '.jpg').delete_prefix("#{stem}_").to_i
      end

      # Each suffix number is strictly greater than the previous (ascending numerical order)
      sorted_suffixes.each_cons(2) do |a, b|
        expect(b).to be > a,
          "Expected ascending numerical order but got #{a} before #{b} in #{sorted_suffixes.inspect}"
      end

      # All input filenames appear in output (no items lost)
      expect(sorted.length).to eq(filenames.length)
      expect(sorted.sort).to eq(filenames.sort)
    }
  end

  it 'handles lexicographic edge cases: _2 sorts before _10' do
    property_of {
      year = range(2020, 2030)
      month = range(1, 12).to_s.rjust(2, '0')
      day = range(1, 28).to_s.rjust(2, '0')

      shortcode_length = range(8, 12)
      shortcode = (1..shortcode_length).map {
        choose(*('A'..'Z').to_a, *('a'..'z').to_a, *('0'..'9').to_a)
      }.join

      stem = "#{year}#{month}#{day}_#{shortcode}"

      # Always include suffixes that would sort differently lexicographically vs numerically
      # e.g., _1, _2, _10, _11, _20 — lexicographic: _1, _10, _11, _2, _20
      tricky_suffixes = [1, 2, 10, 11, 20]
      # Add some random extras
      extra_count = range(0, 5)
      extras = ((3..9).to_a + (12..19).to_a + (21..50).to_a).sample(extra_count)
      all_suffixes = (tricky_suffixes + extras).uniq

      filenames = all_suffixes.map { |n| "#{stem}_#{n}.jpg" }.shuffle

      [stem, filenames, all_suffixes]
    }.check(100) { |stem, filenames, _suffixes|
      sorted = SiStudio::ImageSorter.sort_images(filenames, stem)

      sorted_suffixes = sorted.map do |img|
        File.basename(img, '.jpg').delete_prefix("#{stem}_").to_i
      end

      # Verify _2 comes before _10 (numerical, not lexicographic)
      idx_2 = sorted_suffixes.index(2)
      idx_10 = sorted_suffixes.index(10)
      expect(idx_2).to be < idx_10,
        "Expected _2 (index #{idx_2}) before _10 (index #{idx_10}) but got lexicographic ordering"

      # Overall ascending order holds
      sorted_suffixes.each_cons(2) do |a, b|
        expect(b).to be > a,
          "Expected ascending numerical order but got #{a} before #{b}"
      end
    }
  end

  it 'places unsuffixed image (stem.jpg) first when present' do
    property_of {
      year = range(2020, 2030)
      month = range(1, 12).to_s.rjust(2, '0')
      day = range(1, 28).to_s.rjust(2, '0')

      shortcode_length = range(8, 12)
      shortcode = (1..shortcode_length).map {
        choose(*('A'..'Z').to_a, *('a'..'z').to_a, *('0'..'9').to_a)
      }.join

      stem = "#{year}#{month}#{day}_#{shortcode}"

      # Generate suffixed images + the unsuffixed one
      suffix_count = range(2, 15)
      suffixes = (1..50).to_a.sample(suffix_count)
      filenames = suffixes.map { |n| "#{stem}_#{n}.jpg" }
      filenames << "#{stem}.jpg" # unsuffixed image
      filenames.shuffle!

      [stem, filenames]
    }.check(100) { |stem, filenames|
      sorted = SiStudio::ImageSorter.sort_images(filenames, stem)

      # Unsuffixed image (stem.jpg) appears first
      expect(sorted.first).to eq("#{stem}.jpg"),
        "Expected unsuffixed '#{stem}.jpg' first but got '#{sorted.first}'"

      # Remaining images are in ascending numerical suffix order
      suffixed = sorted[1..]
      sorted_suffixes = suffixed.map do |img|
        File.basename(img, '.jpg').delete_prefix("#{stem}_").to_i
      end

      sorted_suffixes.each_cons(2) do |a, b|
        expect(b).to be > a,
          "Expected ascending order after unsuffixed but got #{a} before #{b}"
      end

      # No items lost
      expect(sorted.length).to eq(filenames.length)
      expect(sorted.sort).to eq(filenames.sort)
    }
  end
end
