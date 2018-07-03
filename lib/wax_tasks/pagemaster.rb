# document
class PagemasterCollection < Collection
  attr_accessor :page_dir, :data

  def initialize(name, opts = {})
    super(name, opts)
    @data     = ingest(@config.fetch('source', nil))
    @layout   = @config.fetch('layout', nil)
    @ordered  = @config.fetch('keep_order', false)
  end

  def generate_pages
    FileUtils.mkdir_p(@page_dir)
    completed = 0
    @data.each_with_index do |item, index|
      page_slug = item.fetch('pid').to_s.slug
      path      = "#{@page_dir}/#{page_slug}.md"

      puts "#{page_slug}.md already exits. Skipping." and next if File.exist?(path)

      item['permalink'] = "/#{@name}/#{page_slug}#{@site_config[:permalink]}"
      item['layout']    = @layout
      item['order']     = padded_int(index, @data.length) if @ordered

      File.open(path, 'w') { |f| f.write("#{item.to_yaml}---") }
      completed += 1
    end
    puts "#{completed} pages were generated to #{@page_dir} directory.".cyan
  rescue KeyError => e
    raise Error::MissingPid, "Failure after #{completed} pages ~> #{e}"
  end

  def padded_int(index, max_idx)
    index.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
  end
end
