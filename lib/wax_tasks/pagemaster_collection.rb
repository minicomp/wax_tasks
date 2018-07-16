module WaxTasks
  # document
  class PagemasterCollection < Collection
    attr_reader :source, :layout, :data, :ordered

    def initialize(name, site)
      super(name, site)

      @source   = source_path
      @layout   = assert_layout
      @data     = Utils.ingest_file(@source)
      @ordered  = @config.fetch(:keep_order, false)
    end

    def source_path
      raise WaxTasks::Error::MissingSource, "Missing collection source in _config.yml for #{@name}" unless @config.key? :source
      WaxTasks::Utils.make_path(@site[:source_dir], '_data', @config[:source])
    end

    def assert_layout
      raise WaxTasks::Error::MissingLayout, "Missing collection layout in _config.yml for #{@name}" unless @config.key? :layout
      @config[:layout]
    end

    def generate_pages(write = true)
      FileUtils.mkdir_p(@page_dir)
      pages = []
      @data.each_with_index do |item, idx|
        page_slug         = item.fetch('pid').to_s.slug
        path              = "#{@page_dir}/#{page_slug}.md"
        item['permalink'] = "/#{@name}/#{page_slug}#{@site[:permalink]}"
        item['layout']    = @layout
        item['order']     = padded_int(idx, @data.length) if @ordered
        pages << item
        next "#{page_slug}.md already exits. Skipping." if File.exist?(path)
        File.open(path, 'w') { |f| f.write("#{item.to_yaml}---") } if write
      end
      puts "#{@data.length} pages were generated to #{@page_dir} directory.".cyan
      pages
    end

    def padded_int(idx, max_idx)
      idx.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
    end
  end
end
