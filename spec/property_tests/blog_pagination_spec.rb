# frozen_string_literal: true

# Feature: premium-interior-design-website, Property 6: Blog Pagination Invariants
# Validates: Requirements 4.6

require 'spec_helper'
require 'si_studio/paginator'

RSpec.describe 'Property 6: Blog Pagination Invariants' do
  it 'produces exactly ceil(N / 12) pages for any total post count N >= 1' do
    property_of {
      range(1, 200)
    }.check(100) { |total_posts|
      pages = SiStudio::Paginator.paginate(total_posts)

      expected_num_pages = (total_posts.to_f / 12).ceil
      expect(pages.length).to eq(expected_num_pages),
        "Expected #{expected_num_pages} pages for #{total_posts} posts, got #{pages.length}"
    }
  end

  it 'each page has at most 12 posts' do
    property_of {
      range(1, 200)
    }.check(100) { |total_posts|
      pages = SiStudio::Paginator.paginate(total_posts)

      pages.each_with_index do |page_size, idx|
        expect(page_size).to be <= 12,
          "Page #{idx + 1} has #{page_size} posts, expected at most 12"
      end
    }
  end

  it 'first page has min(N, 12) posts' do
    property_of {
      range(1, 200)
    }.check(100) { |total_posts|
      pages = SiStudio::Paginator.paginate(total_posts)

      expected_first_page = [total_posts, 12].min
      expect(pages.first).to eq(expected_first_page),
        "First page should have #{expected_first_page} posts for N=#{total_posts}, got #{pages.first}"
    }
  end

  it 'no page has zero posts' do
    property_of {
      range(1, 200)
    }.check(100) { |total_posts|
      pages = SiStudio::Paginator.paginate(total_posts)

      pages.each_with_index do |page_size, idx|
        expect(page_size).to be > 0,
          "Page #{idx + 1} has zero posts, which is not allowed"
      end
    }
  end

  it 'sum of all page post counts equals N' do
    property_of {
      range(1, 200)
    }.check(100) { |total_posts|
      pages = SiStudio::Paginator.paginate(total_posts)

      expect(pages.sum).to eq(total_posts),
        "Sum of page sizes (#{pages.sum}) should equal total posts (#{total_posts})"
    }
  end
end
