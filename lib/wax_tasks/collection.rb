# frozen_string_literal: true

module WaxTasks
  #
  class Collection
    attr_reader :name
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
    def imageable?
      !@imagedata_source.empty? && Dir.exist?(@imagedata_source)
    end

    #
    #
    #
    def pageable?
      !@metadata_source.empty? && File.exist?(@metadata_source)
    end

    #
    #
    #
    def indexable?
      !@page_dir.empty? && Dir.exist?(@page_dir)
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
      @page_dir || Utils.safe_join(@site.source,
                                   @site.collections_dir,
                                   "_#{@name}")
    end

    #
    #
    #
    def metadata_source
      @metadata_source || Utils.safe_join(@site.source,
                                          '_data',
                                          @config.dig('metadata', 'source'))
    end

    #
    #
    #
    def imagedata_source
      @image_source || Utils.safe_join(@site.source,
                                       '_data',
                                       @config.dig('images', 'source'))
    end

    #
    #
    #
    def pagedata
      raise Error::PageLoad, "Cannot find #{@page_dir}" unless Dir.exist? @page_dir

      data  = []
      pages = Dir.glob("#{@page_dir}/*.md")
      puts "There are no pages in #{@page_dir} to index.".orange if pages.empty?

      pages.each do |page|
        begin
          hash = SafeYAML.load_file(page)
          hash['content'] = WaxTasks::Utils.html_strip(File.read(page))
          data << hash
        rescue StandardError => e
          raise Error::PageLoad, "Cannot load page #{p}\n#{e}"
        end
      end
      data
    end

    #
    #
    #
    def metadata
      raise Error::MissingSource, "Cannot find #{@metadata_source}" unless File.exist? @metadata_source

      data = case File.extname(@metadata_source)
             when '.csv'
               WaxTasks::Utils.validate_csv(@metadata_source)
             when '.json'
               WaxTasks::Utils.validate_json(@metadata_source)
             when /\.ya?ml/
               WaxTasks::Utils.validate_yaml(@metadata_source)
             else
               raise Error::InvalidSource, "Can't load #{File.extname(@metadata_source)} files. Culprit: #{@metadata_source}"
             end
      WaxTasks::Utils.assert_pids(data)
      WaxTasks::Utils.assert_unique(data)
    end

    #
    #
    #
    def imagedata; end
  end
end
