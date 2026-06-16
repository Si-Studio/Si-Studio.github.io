# frozen_string_literal: true

module SiStudio
  module PostGenerator
    PLACEHOLDER_IMAGE = '/images/logo/logo.svg'
    DATE_PREFIX_REGEX = /\A(\d{4})(\d{2})(\d{2})_(.+)\z/

    # Parses a filename stem (without extension) into date components and shortcode.
    # Returns [year, month, day, shortcode] or nil if the filename doesn't match.
    #
    # @param stem [String] e.g. "20250207_DFxKBQWsD30"
    # @return [Array<String>, nil]
    def self.parse_filename(stem)
      match = stem.match(DATE_PREFIX_REGEX)
      return nil unless match

      year = match[1]
      month = match[2]
      day = match[3]
      shortcode = match[4]

      # Validate date components
      return nil unless (1..12).include?(month.to_i) && (1..31).include?(day.to_i)

      [year, month, day, shortcode]
    end

    # Extracts a title from text content.
    # Returns first sentence (up to first period or newline), truncated at 80 chars + ellipsis.
    # Returns 'Bez tytułu' for nil/blank text.
    #
    # @param text [String, nil]
    # @return [String]
    def self.extract_title(text)
      return 'Bez tytułu' if text.nil? || text.strip.empty?

      first_sentence = text.split(/[.\n]/, 2).first&.strip || ''
      return 'Bez tytułu' if first_sentence.empty?

      if first_sentence.length > 80
        first_sentence[0, 80] + '…'
      else
        first_sentence
      end
    end

    # Determines the featured image path for a post.
    # If a jpg file exists with the same stem, returns its content-relative path.
    # Otherwise returns the placeholder.
    #
    # @param stem [String] filename stem e.g. "20250207_DFxKBQWsD30"
    # @param available_jpgs [Array<String>] list of available jpg filenames in content dir
    # @return [String] image path
    def self.determine_image(stem, available_jpgs)
      # Check for exact match (stem.jpg) or numbered variants (stem_N.jpg)
      matching = available_jpgs.select { |jpg|
        basename = File.basename(jpg, '.jpg')
        basename == stem || basename.start_with?("#{stem}_")
      }

      if matching.empty?
        PLACEHOLDER_IMAGE
      else
        sorted = sort_images(matching, stem)
        "/images/blog/#{sorted.first}"
      end
    end

    # Sorts image filenames by numeric suffix.
    # Unsuffixed (stem.jpg) comes first, then _1, _2, _3, etc.
    #
    # @param images [Array<String>] image filenames
    # @param stem [String] the filename stem
    # @return [Array<String>] sorted filenames
    def self.sort_images(images, stem)
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

    # Generates a post hash (front matter + body) from input parameters.
    # This is the pure-logic core of post generation, without filesystem I/O.
    #
    # @param stem [String] filename stem e.g. "20250207_DFxKBQWsD30"
    # @param text [String] the text content from the .txt file
    # @param available_jpgs [Array<String>] list of jpg filenames in content dir
    # @return [Hash] with keys :date, :title, :image, :body
    def self.generate_post_data(stem, text, available_jpgs)
      parsed = parse_filename(stem)
      return nil unless parsed

      year, month, day, _shortcode = parsed
      date_str = "#{year}-#{month}-#{day}"
      title = extract_title(text)
      image = determine_image(stem, available_jpgs)

      {
        date: date_str,
        title: title,
        image: image,
        body: text
      }
    end
  end
end
