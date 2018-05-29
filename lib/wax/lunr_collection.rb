# document
class LunrCollection < Collection
  attr_accessor :fields, :data

  def initialize(name, opts = {})
    super(name, opts)
    @content  = @c_conf['lunr_index'].fetch('content', false)
    @fields   = @c_conf['lunr_index'].fetch('fields', nil)
    @data     = pages_to_hash_array
  end

  def pages_to_hash_array
    page_hashes = []
    count = 0
    pages = Dir.glob(@page_dir + '/*.md')
    # catch
    abort "There are no pages in '#{@page_dir}'".magenta if pages.empty?
    abort "There are no fields for #{@name}.".magenta if @fields.empty?
    puts "Loading #{pages.length} pages from #{@page_dir}"
    # index each page in collection
    pages.each do |page|
      page_hashes << page_hash(page, count)
      count += 1
    end
    page_hashes
  end

  def page_hash(page, count)
    yaml = YAML.load_file(page)
    hash = {
      'lunr_id' => count,
      'link' => "{{'" + yaml.fetch('permalink') + "' | relative_url }}",
      'collection' => @name
    }
    @fields.each { |f| hash[f] = rm_diacritics(thing2string(yaml[f])) }
    hash['content'] = rm_diacritics(clean(File.read(page))) if @content
    hash
  end
end
