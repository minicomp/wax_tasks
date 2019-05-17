# frozen_string_literal: true

module WaxTasks
  #
  class Collection
    attr_reader :name, :config, :ext, :search_fields,
                :page_source, :metadata_source, :imagedata_source

    #
    #
    #
    def initialize(name, config, source, collections_dir, ext)
      @name             = name
      @config           = config
      @page_extension   = ext
      @site_source      = source
      @page_source      = Utils.safe_join(source, collections_dir, "_#{name}")
      @metadata_source  = Utils.safe_join(source, '_data', config.dig('metadata', 'source'))
      @imagedata_source = Utils.safe_join(source, '_data', config.dig('images', 'source'))
      @search_fields    = %w[pid label thumbnail permalink collection]
      @image_variants   = image_variants
    end

    def image_variants
      default_variants = { 'thumbnail': 250, 'full': 1140 }
      custom_variants  = @config.dig('images', 'variants') || {}

      default_variants.merge custom_variants
    end

    def iiif_config
      @config.dig 'images', 'iiif' || {}
    end

    def search_fields=(fields)
      @search_fields.concat(fields).flatten.compact.uniq
    end

    def records_from_pages
      paths = Dir.glob("#{@page_source}/*.{md, markdown}")
      warn Rainbow("There are no pages in #{@page_source} to index.").orange if paths.empty?

      paths.map do |path|
        begin
          content = WaxTasks::Utils.content_clean(File.read(path))
          Record.new(SafeYAML.load_file(path)).tap do |r|
            r.set('content', content)
            r.set('permalink', "/#{@name}/#{r.pid}#{@ext}") unless r.permalink?
          end
        rescue StandardError => e
          raise Error::PageLoad, "Cannot load page #{path}\n#{e}"
        end
      end
    end

    def records_from_metadata
      raise Error::MissingSource, "Cannot find metadata source '#{@metadata_source}'" unless File.exist? @metadata_source

      metadata = Utils.ingest(@metadata_source)
      metadata.each_with_index.map do |meta, i|
        Record.new(meta).tap do |r|
          r.set('order', Utils.padded_int(i, metadata.length))
          r.set('layout', @config['layout']) if @config.key? 'layout'
          r.set('collection', @name)
        end
      end
    end

    def items_from_imagedata
      raise Error::MissingSource, "Cannot find image data source '#{@imagedata_source}'" unless Dir.exist? @imagedata_source

      @records = records_from_metadata
      item_paths.map do |path|
        item = WaxTasks::Item.new(path, @image_variants)
        next unless item.valid?

        item.record = @records.find { |r| r.pid == item.pid }
        warn Rainbow("\nWarning:\nCould not find record in #{@metadata_source} for image item #{path}.\n").orange if item.record.nil?
        item
      end.compact
    end

    def item_paths
      pre_process_pdfs
      Dir.glob(Utils.safe_join(@imagedata_source, '*'))
    end

    def pre_process_pdfs
      Dir.glob(Utils.safe_join(@imagedata_source, '*.pdf')).each do |path|
        target_dir = path.gsub '.pdf', ''
        next unless Dir.glob("#{target_dir}/*").empty?

        puts Rainbow("\nPreprocessing #{path} into image files. This may take a minute.\n").cyan
        opts = { output_dir: File.dirname(target_dir) }
        WaxIiif::Utilities::PdfSplitter.split(path, opts).sort
      end
    end

    def write_simple_derivatives(dir)
      items_from_imagedata.map do |item|
        item.simple_derivatives.each do |d|
          path = "#{dir}/#{d.path}"
          FileUtils.mkdir_p(File.dirname(path))
          next if File.exist?(path)

          d.img.write(path)
          relative_path = path.gsub @site_source, ''
          puts Rainbow("Writing #{relative_path}").cyan
          item.record.set(d.label, relative_path) if item.record?
        end
        item
      end.flat_map(&:record)
    end

    def update_metadata(update)
      records = consolidate_records(records_from_metadata, update)
      reformatted = case File.extname @metadata_source
                    when '.csv'
                      csv_string records
                    when '.json'
                      json_string records
                    when /\.ya?ml/
                      records.to_yaml
                    end
      File.open(@metadata_source, 'w') { |f| f.puts reformatted }
    end

    def consolidate_records(original, new)
      lost_record_pids = original.map(&:pid) - new.map(&:pid)
      lost_record_pids.each do |pid|
        new << original.find { |r| r.pid == pid }
      end
      new
    end

    def csv_string(records)
      keys = records.flat_map(&:keys).uniq
      CSV.generate do |csv|
        csv << keys
        records.each do |r|
          csv << keys.map { |k| r.hash.fetch(k, '')  }
        end
      end
    end

    def json_string(records)
      hashes = records.map(&:hash)
      JSON.pretty_generate(hashes)
    end
  end
end
