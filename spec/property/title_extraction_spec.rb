# frozen_string_literal: true

require 'spec_helper'
require 'rantly'
require 'rantly/rspec_extensions'
require 'si_studio/title_extractor'

# Feature: premium-interior-design-website, Property 4: Blog Title Extraction
# Validates: Requirements 4.3
#
# For any non-empty text string, the title extraction function SHALL return a string
# that is either: (a) the substring up to the first period or newline character if that
# substring is ≤ 80 characters, or (b) the first 80 characters of the text followed by
# "…" if no period or newline occurs within the first 80 characters. The result SHALL
# never exceed 81 characters (80 + ellipsis character).
RSpec.describe SiStudio::TitleExtractor, '.extract_title' do
  # Character sets for generators
  # Characters that won't trigger sentence splitting (no period, no newline)
  SAFE_REGEX = /[A-Za-z0-9 ,;:!?\-ąćęłńóśźż]/

  context 'Property 4: Blog Title Extraction' do
    it 'result length never exceeds 81 characters (80 + ellipsis)' do
      property_of {
        len = range(1, 250)
        # Mix safe chars with occasional periods/newlines
        base = sized(len) { string(SAFE_REGEX) }
        # Randomly insert periods or newlines
        insertions = range(0, 3)
        text = base.dup
        insertions.times do
          pos = range(0, [text.length - 1, 0].max)
          char = choose('.', "\n")
          text.insert(pos, char)
        end
        text
      }.check(200) { |text|
        result = SiStudio::TitleExtractor.extract_title(text)
        expect(result.length).to be <= 81,
          "Expected result length <= 81 but got #{result.length} for input of length #{text.length}"
      }
    end

    it 'returns text up to first period if period occurs within first 80 chars' do
      property_of {
        # Generate a non-empty prefix with no periods or newlines (1-79 chars)
        prefix_len = range(1, 79)
        prefix = sized(prefix_len) { string(SAFE_REGEX) }
        # Ensure prefix has non-whitespace content
        guard(!prefix.strip.empty?)
        # Add a period and optional suffix
        suffix_len = range(0, 100)
        suffix = sized(suffix_len) { string(SAFE_REGEX) }
        text = prefix + '.' + suffix
        [prefix, text]
      }.check(200) { |(prefix, text)|
        result = SiStudio::TitleExtractor.extract_title(text)
        expected = prefix.strip
        expect(result).to eq(expected),
          "Expected '#{expected}' but got '#{result}'"
      }
    end

    it 'returns text up to first newline if newline occurs within first 80 chars' do
      property_of {
        # Generate a non-empty prefix with no periods or newlines (1-79 chars)
        prefix_len = range(1, 79)
        prefix = sized(prefix_len) { string(SAFE_REGEX) }
        # Ensure prefix has non-whitespace content
        guard(!prefix.strip.empty?)
        # Add a newline and optional suffix
        suffix_len = range(0, 100)
        suffix = sized(suffix_len) { string(SAFE_REGEX) }
        text = prefix + "\n" + suffix
        [prefix, text]
      }.check(200) { |(prefix, text)|
        result = SiStudio::TitleExtractor.extract_title(text)
        expected = prefix.strip
        expect(result).to eq(expected),
          "Expected '#{expected}' but got '#{result}'"
      }
    end

    it 'returns first 80 chars + "…" when no period/newline in first 80 chars and text is longer' do
      property_of {
        # Generate text > 80 chars with no periods or newlines
        len = range(81, 250)
        text = sized(len) { string(SAFE_REGEX) }
        # Ensure first char is non-whitespace
        text[0] = 'A' if text[0] == ' '
        guard(text.strip.length > 80)
        text
      }.check(200) { |text|
        result = SiStudio::TitleExtractor.extract_title(text)
        # The function: split on [.\n] (none found) -> get full text -> strip -> truncate
        stripped = text.strip
        expected = stripped[0, 80] + '…'
        expect(result).to eq(expected),
          "Expected truncation at 80 chars + ellipsis, got '#{result[0, 30]}...' (len=#{result.length})"
      }
    end

    it 'returns input stripped when short (≤80 chars) with no period/newline' do
      property_of {
        # Generate text 1-80 chars with no periods or newlines
        len = range(1, 80)
        text = sized(len) { string(SAFE_REGEX) }
        # Ensure non-empty after strip
        guard(!text.strip.empty?)
        text
      }.check(200) { |text|
        result = SiStudio::TitleExtractor.extract_title(text)
        expected = text.strip
        expect(result).to eq(expected),
          "Expected '#{expected}' but got '#{result}'"
      }
    end

    it 'result never contains newline characters' do
      property_of {
        len = range(1, 200)
        base = sized(len) { string(SAFE_REGEX) }
        # Insert some newlines randomly
        insertions = range(0, 5)
        text = base.dup
        insertions.times do
          pos = range(0, [text.length - 1, 0].max)
          text.insert(pos, "\n")
        end
        text
      }.check(200) { |text|
        result = SiStudio::TitleExtractor.extract_title(text)
        expect(result).not_to include("\n"),
          "Result should not contain newline, got: #{result.inspect}"
      }
    end

    it 'returns "Bez tytułu" for empty or whitespace-only strings' do
      property_of {
        # Generate whitespace-only strings
        len = range(0, 20)
        ' ' * len
      }.check(100) { |text|
        result = SiStudio::TitleExtractor.extract_title(text)
        expect(result).to eq('Bez tytułu')
      }
    end
  end
end
