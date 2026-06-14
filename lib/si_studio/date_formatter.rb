# frozen_string_literal: true

module SiStudio
  module DateFormatter
    # Formats a date string from YYYYMMDD to DD.MM.YYYY
    #
    # @param yyyymmdd_string [String] date in YYYYMMDD format (e.g. "20250207")
    # @return [String] date in DD.MM.YYYY format (e.g. "07.02.2025")
    def self.format_display_date(yyyymmdd_string)
      year = yyyymmdd_string[0, 4]
      month = yyyymmdd_string[4, 2]
      day = yyyymmdd_string[6, 2]

      "#{day}.#{month}.#{year}"
    end
  end
end
