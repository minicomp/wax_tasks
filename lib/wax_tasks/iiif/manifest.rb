module WaxTasks
  module Iiif
    # Module for handling metadata in IIIF manifests
    module Manifest
      # @return [String]
      def label
        @image_config.dig('iiif', 'label')
      end

      # @return [String]
      def description
        @image_config.dig('iiif', 'description')
      end

      # @return [String]
      def attribution
        @image_config.dig('iiif', 'attribution')
      end

      # @return [String]
      def logo
        @image_config.dig('iiif', 'logo')
      end
    end
  end
end
