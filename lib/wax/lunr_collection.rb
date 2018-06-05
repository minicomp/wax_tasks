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
    pages = Dir.glob(@page_dir + '/*.md')
    # catch
    abort "There are no pages in '#{@page_dir}'".magenta if pages.empty?
    abort "There are no fields for #{@name}.".magenta if @fields.empty?
    puts "Loading #{pages.length} pages from #{@page_dir}"
    # index each page in collection
    pages.each { |page| page_hashes << page_hash(page) }
    page_hashes
  end

  def page_hash(page)
    yaml = YAML.load_file(page)
    hash = {
      'link' => "{{'" + yaml.fetch('permalink') + "' | relative_url }}",
      'collection' => @name
    }
    hash['content'] = rm_diacritics(clean(File.read(page))) if @content
    @fields.each do |f|
      value = yaml[f]
      hash[f] = case value
                when Array
                  rm_diacritics(value.join(', '))
                when String
                  rm_diacritics(value)
                when Hash
                  value
                else
                  value.to_s
                end
    end
    hash
  end
end
