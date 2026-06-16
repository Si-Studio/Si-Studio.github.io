# frozen_string_literal: true

require 'rspec'
require 'rantly'
require 'rantly/rspec_extensions'
require_relative '../../lib/si_studio/date_formatter'

# **Validates: Requirements 4.2**
#
# Property 3: Date Format Transformation
# For any valid date in YYYYMMDD format (where YYYY is 2020–2030, MM is 01–12,
# DD is 01–31 and valid for the given month), formatting to DD.MM.YYYY SHALL
# produce a string where the day and month are zero-padded two-digit numbers
# separated by dots, and parsing the output back SHALL yield the original date
# components.

DAYS_IN_MONTH = lambda { |year, month|
  case month
  when 1, 3, 5, 7, 8, 10, 12 then 31
  when 4, 6, 9, 11 then 30
  when 2
    if (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
      29
    else
      28
    end
  end
}

RSpec.describe SiStudio::DateFormatter, 'Feature: premium-interior-design-website, Property 3: Date Format Transformation' do
  it 'produces DD.MM.YYYY format matching pattern and roundtrips back to original components' do
    property_of {
      year = range(2020, 2030)
      month = range(1, 12)
      max_day = DAYS_IN_MONTH.call(year, month)
      day = range(1, max_day)

      year_str = year.to_s.rjust(4, '0')
      month_str = month.to_s.rjust(2, '0')
      day_str = day.to_s.rjust(2, '0')

      [year_str, month_str, day_str, "#{year_str}#{month_str}#{day_str}"]
    }.check(100) { |year_str, month_str, day_str, input|
      result = SiStudio::DateFormatter.format_display_date(input)

      # Output is always exactly 10 characters long
      expect(result.length).to eq(10)

      # Output matches DD.MM.YYYY pattern
      expect(result).to match(/^\d{2}\.\d{2}\.\d{4}$/)

      # Parse output back
      parts = result.split('.')
      out_day = parts[0]
      out_month = parts[1]
      out_year = parts[2]

      # Day component is zero-padded (01–31)
      expect(out_day.length).to eq(2)
      expect(out_day.to_i).to be_between(1, 31)

      # Month component is zero-padded (01–12)
      expect(out_month.length).to eq(2)
      expect(out_month.to_i).to be_between(1, 12)

      # Year component is four digits
      expect(out_year.length).to eq(4)

      # Roundtrip: parsing the output yields original components
      expect(out_day).to eq(day_str)
      expect(out_month).to eq(month_str)
      expect(out_year).to eq(year_str)

      # Additional roundtrip: reconstructing YYYYMMDD from output equals input
      reconstructed = "#{out_year}#{out_month}#{out_day}"
      expect(reconstructed).to eq(input)
    }
  end
end
