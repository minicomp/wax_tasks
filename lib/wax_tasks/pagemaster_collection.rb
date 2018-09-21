module WaxTasks
  # A Jekyll collection with a data source file that
  # can generate markdown pages from that data.
  #
  # @attr source  [String]  the path to the data source file
  # @attr layout  [String]  the Jekyll layout to be used by the generated pages
  # @attr data    [Array]   array of hashes representing the ingested data file
  # @attr ordered [Boolean] whether/not the order of items should be preserved
  class PagemasterCollection < Collection
    attr_reader :source, :layout, :data, :ordered

    # Creates a new PagemasterCollection with name @name given site config @site
    def initialize(name, site)
      super(name, site)

      @source   = source_path
      @layout   = assert_layout
      @data     = ingest_file(@source)
      @ordered  = @config.fetch('keep_order', false)
    end

    # Constructs the path to the data source file
    #
    # @return [String] the path to the data source file
    def source_path
      raise WaxTasks::Error::MissingSource, "Missing collection source in _config.yml for #{@name}" unless @config.key? 'source'
      WaxTasks::Utils.make_path(@site[:source_dir], '_data', @config['source'])
    end

    # Confirms + requires `layout` value in the collection @config
    #
    # @return [String] the Jekyll layout to be used by the generated pages
    def assert_layout
      raise WaxTasks::Error::MissingLayout, "Missing collection layout in _config.yml for #{@name}" unless @config.key? 'layout'
      @config['layout']
    end

    # Writes markdown pages from the ingested data to @page_dir
    # with layout, permalink, and order info added (if applicable)
    #
    # @return [Array] a copy of the pages as hashes, for testing
    def generate_pages
      FileUtils.mkdir_p(@page_dir)
      pages = []
      @data.each_with_index do |item, idx|
        page_slug         = Utils.slug(item.fetch('pid'))
        path              = "#{@page_dir}/#{page_slug}.md"
        item['permalink'] = "/#{@name}/#{page_slug}#{@site[:permalink]}"
        item['layout']    = @layout
        item['order']     = padded_int(idx, @data.length) if @ordered
        pages << item
        next "#{page_slug}.md already exits. Skipping." if File.exist?(path)
        File.open(path, 'w') { |f| f.write("#{item.to_yaml}---") }
      end
      puts "#{@data.length} pages were generated to #{@page_dir} directory.".cyan
      pages
    end

    # Constructs the order variable for each page (if the collection
    # needs to preserve the order of items from the file)
    #
    # @return [Integer] the order if the item padded with '0's for sorting
    def padded_int(idx, max_idx)
      idx.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
    end
  end
end
