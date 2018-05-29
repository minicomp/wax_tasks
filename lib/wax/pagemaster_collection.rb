
# document
class PagemasterCollection < Collection
  attr_accessor :page_dir

  def initialize(name, opts = {})
    super(name, opts)
    @data     = ingest(@c_conf.fetch('source', nil))
    @layout   = @c_conf.fetch('layout', nil)
    @ordered  = @c_conf.fetch('keep_order', false)
  end

  def generate_pages
    FileUtils.mkdir_p(@page_dir)
    completed = 0
    skipped = 0

    @data.each_with_index do |item, i|
      name = slug(item.fetch('pid').to_s)
      path = "#{@page_dir}/#{name}.md"
      if File.exist?(path)
        puts "#{name}.md already exits. Skipping."
        skipped += 1
      else
        page = page(item, name, i).to_yaml
        File.open(path, 'w') { |f| f.write("#{page}---") }
        completed += 1
      end
    end
    puts Message.pagemaster_results(completed, skipped, @page_dir)
  rescue StandardError => e
    Error.page_generation_failure(completed) + "\n#{e}"
  end

  def page(item, name, index)
    item['permalink'] = "/#{@name}/#{name}#{@s_conf[:permalink]}"
    item['layout']    = @layout
    item['order']     = padded_int(index, @data.length) if @ordered
    item
  end

  def padded_int(index, max_idx)
    index.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
  end
end
