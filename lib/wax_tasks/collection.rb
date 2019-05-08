# frozen_string_literal: true

module WaxTasks
  #
  class Collection
    attr_reader :name

    #
    #
    #
    def initialize(site, name)
      @site             = site
      @name             = name
      @config           = config
      @layout           = layout
      @page_dir         = page_dir
      @metadata_source  = metadata_source
      @imagedata_source = imagedata_source
    end

    #
    #
    #
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
      raise Error::MissingSource, "Cannot find metadata source '#{@metadata_source}'" unless File.exist? @metadata_source

      meta = WaxTasks::Utils.ingest(@metadata_source)

      WaxTasks::Utils.assert_pids(meta)
      WaxTasks::Utils.assert_unique(meta)

      meta.map { |m| Record.new(m) }
    end

    #
    #
    #
    def imagedata
      raise Error::MissingSource, "Cannot find image data source '#{@imagedata_source}'" unless Dir.exist? @imagedata_source

      paths = Dir.glob(Utils.safe_join(@imagedata_source, '*'))
      paths.each do |path|
        item = WaxTasks::Item.new(path)
        item.record = metadata.find { |m| m['pid'] == item.pid }
      end
    end
  end
end
