# frozen_string_literal: true

require 'spec_helper'
require 'rantly'
require 'rantly/rspec_extensions'
require 'si_studio/title_formatter'

# Feature: premium-interior-design-website, Property 1: Folder Name to Display Title Transformation
# **Validates: Requirements 3.2**
#
# For any project folder name string containing underscores, replacing underscores
# with spaces and applying title-case capitalization SHALL produce a string where
# every word starts with a capital letter and contains no underscore characters.

RSpec.describe SiStudio::TitleFormatter, '.format_project_title' do
  describe 'Property 1: Folder Name to Display Title Transformation' do
    it 'produces a title with no underscores and every word capitalized for any folder name' do
      property_of {
        # Generate a folder name: 1-5 words separated by underscores
        # Each word is 1-15 lowercase letters/digits
        word_count = range(1, 5)
        words = Array.new(word_count) {
          len = range(1, 15)
          chars = Array.new(len) { freq([8, :call, proc { Rantly.new.choose(*('a'..'z').to_a) }],
                                        [2, :call, proc { Rantly.new.choose(*('0'..'9').to_a) }]) }
          chars.join
        }
        words.join('_')
      }.check(100) { |folder_name|
        result = SiStudio::TitleFormatter.format_project_title(folder_name)

        # Property: result contains no underscore characters
        expect(result).not_to include('_'),
          "Expected no underscores in '#{result}' (input: '#{folder_name}')"

        # Property: every word starts with a capital letter
        result.split(' ').each do |word|
          next if word.empty?
          first_char = word[0]
          # Only check alphabetic first characters (digits don't capitalize)
          if first_char.match?(/[a-zA-Z]/)
            expect(first_char).to eq(first_char.upcase),
              "Expected word '#{word}' to start with capital letter in '#{result}' (input: '#{folder_name}')"
          end
        end

        # Property: word count is preserved (underscores + 1 = number of output words)
        expected_word_count = folder_name.count('_') + 1
        actual_word_count = result.split(' ').length
        expect(actual_word_count).to eq(expected_word_count),
          "Expected #{expected_word_count} words but got #{actual_word_count} in '#{result}' (input: '#{folder_name}')"
      }
    end
  end
end
