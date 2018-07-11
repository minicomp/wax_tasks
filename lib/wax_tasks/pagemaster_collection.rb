# document
module WaxTasks
  # document
  class PagemasterCollection < Collection
    attr_accessor :name, :page_dir, :source,
                  :layout, :ordered, :data

    def initialize(name, opts = {})
      super(name, opts)

      @source   = @config.fetch('source', nil)
      @layout   = @config.fetch('layout', nil)
      @ordered  = @config.fetch('keep_order', false)
      @data     = ingest(@source)
    end

    def generate_pages
      FileUtils.mkdir_p(@page_dir)
      @data.each_with_index { |item, i| write_page(item, i) }
      puts "#{@data.length} pages were generated to #{@page_dir} directory.".cyan
    end

    def write_page(item, index)
      page_slug         = item.fetch('pid').to_s.slug
      path              = "#{@page_dir}/#{page_slug}.md"

      return puts "#{page_slug}.md already exits. Skipping." if File.exist?(path)
      item['permalink'] = "/#{@name}/#{page_slug}#{@site_config[:permalink]}"
      item['layout']    = @layout
      item['order']     = padded_int(index, @data.length) if @ordered

      File.open(path, 'w') { |f| f.write("#{item.to_yaml}---") }
    rescue StandardError => e
      raise Error::PageFailure, "Failure on page #{page_slug} ~> #{e}"
    end

    def padded_int(index, max_idx)
      index.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
    end
  end
end
