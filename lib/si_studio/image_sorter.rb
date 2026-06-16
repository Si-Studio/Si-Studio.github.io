# frozen_string_literal: true

module SiStudio
  module ImageSorter
    # Sorts image filenames sharing the same stem by their numeric suffix.
    # Unsuffixed images (stem.jpg) sort first (position -1).
    # Suffixed images (stem_N.jpg) sort in ascending numerical order.
    #
    # @param images [Array<String>] list of image filenames (e.g. ["20250207_DFxKBQWsD30_3.jpg", ...])
    # @param stem [String] the common prefix (e.g. "20250207_DFxKBQWsD30")
    # @return [Array<String>] images sorted by numeric suffix in ascending order
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
  end
end
