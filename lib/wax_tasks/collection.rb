# frozen_string_literal: true

module WaxTasks
  #
  class Collection
    attr_reader :name
    attr_accessor :search_fields

    #
    #
    #
    def initialize(name, config, site_source, site_collections_dir, site_ext)
      @name                 = name
      @config               = config
      @site_source_dir      = site_source
      @site_collections_dir = site_collections_dir
      @site_ext             = site_ext
      @metadata_source      = metadata_source
      @imagedata_source     = imagedata_source
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
    def layout
      @config.dig('layout')
    end

    #
    #
    #
    def content=(content)
      @content = !!content
    end

    #
    #
    #
    def content?
      @content || false
    end

    # Returns the designated directory for collection pages
    #
    # @return [String] path
    def page_dir
      Utils.safe_join(@site_source_dir, @site_collections_dir, "_#{@name}")
    end

    #
    #
    #
    def metadata_source
      Utils.safe_join(@site_source_dir, '_data', @config.dig('metadata', 'source'))
    end

    #
    #
    #
    def imagedata_source
      Utils.safe_join(@site_source_dir, '_data', @config.dig('images', 'source'))
    end

    #
    #
    #
    def pagedata
      pages = Dir.glob("#{page_dir}/*.md")
      warn Rainbow("There are no pages in #{page_dir} to index.").orange if pages.empty?

      pages.map do |page|
        begin
          record = Record.new(SafeYAML.load_file(page))
          record.content = WaxTasks::Utils.html_strip(File.read(page))
          record.permalink = "/#{@name}/#{record.pid}#{@site_ext}"
          record
        rescue StandardError => e
          raise Error::PageLoad, "Cannot load page #{page}\n#{e}"
        end
      end
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

      pdfs = Dir.glob(Utils.safe_join(@imagedata_source, '*.pdf'))
      pdfs.each { |p| WaxTasks::Utils.process_pdf(p) }

      paths = Dir.glob(Utils.safe_join(@imagedata_source, '*'))
      paths.map do |path|
        type = Dir.exist?(path) ? 'dir' : File.extname(path)
        next unless %w[.png .jpg .jpeg .tiff dir].include? type

        item = WaxTasks::Item.new(path, type)
        item.record = metadata.find { |r| r.pid == item.pid }
        warn Rainbow("\nWarning:\nCould not find record in #{@metadata_source} for image item #{path}.\n").orange if item.record.nil?
        item
      end.compact
    end
  end
end
