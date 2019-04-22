# frozen_string_literal: true

require 'wax_tasks/imagedata'
require 'wax_tasks/metadata'
require 'wax_tasks/pagedata'

module WaxTasks
  class Collection
    include WaxTasks::Pagedata
    include WaxTasks::Metadata
    # include WaxTasks::Imagedata

    # Creates a new collection with name @name given site configuration @site
    #
    # @param  name      [String]  name of the collection in site:collections
    # @param  site      [Hash]    site config
    def initialize(site, name)
      @site             = site
      @name             = name
      @config           = config
      @layout           = layout
      @page_dir         = page_dir
      @metadata_source  = metadata_source
      @imagedata_source = imagedata_source
    end

    # Finds the collection config within the site config
    #
    # @return [Hash] the config for the collection
    def config
      @site.collections.fetch(@name)
    rescue StandardError => e
      raise Error::InvalidCollection, "Cannot load collection config for #{@name}.\n#{e}"
    end

    #
    #
    #
    def layout
      @layout || @config.dig('layout')
    end

    # Returns the designated directory for collection pages
    #
    # @return [String] path
    def page_dir
      @page_dir || Utils.safe_join(@site.source, @site.collections_dir, "_#{@name}")
    end
    alias_method :pagedata_source, :page_dir

    #
    #
    #
    def metadata_source
      @metadata_source || Utils.safe_join(@site.source, '_data', @config.dig('metadata', 'source'))
    end

    #
    #
    #
    def imagedata_source
      @image_source || @config.dig('images', 'source')
    end
  end
end
