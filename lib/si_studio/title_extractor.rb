# frozen_string_literal: true

module SiStudio
  module TitleExtractor
    # Extracts a title from blog post text.
    # Returns the first sentence (up to first period or newline),
    # truncated at 80 characters + "…" if needed.
    #
    # @param text [String, nil] raw blog post text
    # @return [String] extracted title, never exceeds 81 characters (80 + ellipsis)
    def self.extract_title(text)
      return 'Bez tytułu' if text.nil? || text.strip.empty?

      # First sentence: up to first period or newline
      first_sentence = text.split(/[.\n]/, 2).first&.strip || ''
      return 'Bez tytułu' if first_sentence.empty?

      if first_sentence.length > 80
        first_sentence[0, 80] + '…'
      else
        first_sentence
      end
    end
  end
end
