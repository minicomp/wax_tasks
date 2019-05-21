# frozen_string_literal: true

require_relative 'collection/images'
require_relative 'collection/metadata'

module WaxTasks
  #
  class Collection
    attr_reader :name, :config, :ext, :search_fields,
                :page_source, :metadata_source, :imagedata_source

    include Collection::Metadata
    include Collection::Images

    #
    #
    def initialize(name, config, source, collections_dir, ext)
      @name             = name
      @config           = config
      @page_extension   = ext
      @site_source      = source
      @page_source      = Utils.safe_join source, collections_dir, "_#{name}"
      @metadata_source  = Utils.safe_join source, '_data', config.dig('metadata', 'source')
      @imagedata_source = Utils.safe_join source, '_data', config.dig('images', 'source')
      @search_fields    = %w[pid label thumbnail permalink collection]
      @image_variants   = image_variants
    end
  end
end
