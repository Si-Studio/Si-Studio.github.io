# frozen_string_literal: true

module SiStudio
  module TitleFormatter
    # Transforms a project folder name into a display title.
    # Replaces underscores with spaces and applies title-case capitalization.
    #
    # @param folder_name [String] e.g. "apartament_premium_nad_morzem"
    # @return [String] e.g. "Apartament Premium Nad Morzem"
    def self.format_project_title(folder_name)
      folder_name
        .gsub('_', ' ')
        .split(' ')
        .map(&:capitalize)
        .join(' ')
    end
  end
end
