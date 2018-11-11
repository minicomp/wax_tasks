module WaxTasks
  # A Jekyll collection with a data source file that
  # can generate markdown pages from that data.
  #
  # @attr config    [Hash]    the collection config
  # @attr layout    [String]  Jekyll layout to be used by the generated pages
  # @attr ordered   [Boolean] whether/not the order of items should be preserved
  # @attr metadata  [Array]   array of hashes from ingested metadata file
  class PagemasterCollection < Collection
    attr_reader :layout, :ordered, :metadata

    # Creates a new PagemasterCollection with name @name given site config @site
    def initialize(name, site)
      super(name, site)

      @config   = self.config
      @layout   = assert_layout
      @ordered  = @config.fetch('keep_order', false)
      @metadata = ingest_file(self.metadata_source_path)
    end

    # Confirms + requires `layout` value in the collection @config
    #
    # @return [String] the Jekyll layout to be used by the generated pages
    def assert_layout
      raise WaxTasks::Error::MissingLayout, "Missing collection layout in _config.yml for #{@name}" unless @config.key? 'layout'
      @config['layout']
    end

    # Writes markdown pages from the ingested data to page_dir
    # with layout, permalink, and order info added (if applicable)
    #
    # @return [Array] a copy of the pages as hashes, for testing
    def generate_pages
      page_dir = self.page_dir
      FileUtils.mkdir_p(page_dir)
      pages = []
      @metadata.each_with_index do |item, idx|
        page_slug         = Utils.slug(item.fetch('pid'))
        path              = "#{page_dir}/#{page_slug}.md"
        item['permalink'] = "/#{@name}/#{page_slug}#{@site[:permalink]}"
        item['layout']    = @layout
        item['order']     = padded_int(idx, @metadata.length) if @ordered
        pages << item
        next "#{page_slug}.md already exits. Skipping." if File.exist?(path)
        File.open(path, 'w') { |f| f.write("#{item.to_yaml}---") }
      end
      puts "#{@metadata.length} pages were generated to #{page_dir} directory.".cyan
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
