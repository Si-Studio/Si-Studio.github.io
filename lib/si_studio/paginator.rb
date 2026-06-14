# frozen_string_literal: true

module SiStudio
  module Paginator
    # Computes pagination metadata for a given total post count.
    # Returns an array of page sizes where each element represents
    # the number of posts on that page (1-indexed conceptually).
    #
    # @param total_posts [Integer] total number of posts (must be >= 1)
    # @param per_page [Integer] maximum posts per page (default: 12)
    # @return [Array<Integer>] array of post counts per page
    # @raise [ArgumentError] if total_posts < 1 or per_page < 1
    def self.paginate(total_posts, per_page = 12)
      raise ArgumentError, "total_posts must be >= 1" if total_posts < 1
      raise ArgumentError, "per_page must be >= 1" if per_page < 1

      num_pages = (total_posts.to_f / per_page).ceil
      pages = []

      remaining = total_posts
      num_pages.times do
        page_size = [remaining, per_page].min
        pages << page_size
        remaining -= page_size
      end

      pages
    end
  end
end
