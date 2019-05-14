# frozen_string_literal: true

module WaxTasks
  #
  class Collection
    attr_reader :name, :page_source, :metadata_source, :imagedata_source, :search_fields

    @@default_variants = Hashie::Mash.new(thumbnail: 250, full: 1140)

    #
    #
    #
    def initialize(name, config, site)
      @name             = name
      @config           = config
      @site             = site
      @page_source      = page_source
      @metadata_source  = metadata_source
      @imagedata_source = imagedata_source
      @search_fields    = %w[pid label thumbnail permalink]
      @image_variants   = image_variants
      @iiif_config      = iiif_config
    end

    def page_source
      Utils.safe_join(@site.source, @site.collections_dir, "_#{@name}")
    end

    def metadata_source
      Utils.safe_join(@site.source, '_data', @config.dig('metadata', 'source'))
    end

    def imagedata_source
      Utils.safe_join(@site.source, '_data', @config.dig('images', 'source'))
    end

    def image_variants
      custom_variants = Hashie::Mash.new(@config.dig('images', 'variants'))
      @@default_variants.merge(custom_variants)
    end

    def iiif_config
      Hashie::Mash.new(@config.dig('images', 'iiif'))
    end

    def search_fields=(search_config)
      fields = @search_fields
      fields << search_config.fields if search_config.fields
      fields << 'content' if search_config.content
      @search_fields = fields.flatten.compact.uniq
    end

    def records_from_pages
      pages = Dir.glob("#{@page_source}/*.{md, markdown}")
      warn Rainbow("There are no pages in #{@page_source} to index.").orange if pages.empty?

      pages.map do |page|
        begin
          record           = Record.new(SafeYAML.load_file(page))
          record.content   = WaxTasks::Utils.content_clean(File.read(page))
          record.permalink = "/#{@name}/#{record.pid}#{@site_ext}"
          record
        rescue StandardError => e
          raise Error::PageLoad, "Cannot load page #{page}\n#{e}"
        end
      end
    end

    def records_from_metadata
      raise Error::MissingSource, "Cannot find metadata source '#{@metadata_source}'" unless File.exist? @metadata_source

      metadata = WaxTasks::Utils.ingest(@metadata_source)
      WaxTasks::Utils.assert_pids(metadata)
      WaxTasks::Utils.assert_unique(metadata)

      metadata.each_with_index.map do |m, i|
        record            = Record.new(m)
        record.order      = Utils.padded_int(i, metadata.length)
        record.layout     = @config.layout unless @config.layout.nil?
        record.collection = @name
        record
      end
    end

    def items_from_imagedata
      raise Error::MissingSource, "Cannot find image data source '#{@imagedata_source}'" unless Dir.exist? @imagedata_source

      pre_process_pdfs
      Dir.glob(Utils.safe_join(@imagedata_source, '*')).map do |path|
        item = WaxTasks::Item.new(path, @image_variants)
        next unless item.valid?

        item.record = records_from_metadata.find { |r| r.pid == item.pid }
        warn Rainbow("\nWarning:\nCould not find record in #{@metadata_source} for image item #{path}.\n").orange if item.record.nil?
        item
      end.compact
    end

    def pre_process_pdfs
      Dir.glob(Utils.safe_join(@imagedata_source, '*.pdf')).each do |path|
        target_dir = path.gsub('.pdf', '')
        return unless Dir.glob("#{target_dir}/*").empty?

        puts Rainbow("\nPreprocessing #{path} into image files. This may take a minute.\n").cyan
        opts = { output_dir: File.dirname(target_dir) }
        WaxIiif::Utilities::PdfSplitter.split(path, opts).sort
      end
    end
  end
end
