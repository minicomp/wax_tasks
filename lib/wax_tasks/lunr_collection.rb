require_relative 'lunr_index'
require_relative 'lunr_ui'

# document
class LunrCollection < Collection
  attr_accessor :fields, :data

  def initialize(name, opts = {})
    super(name, opts)
    @content  = @config['lunr_index'].fetch('content', false)
    @fields   = @config['lunr_index'].fetch('fields', nil)
    @data     = hash_array(Dir.glob(@page_dir + '/*.md'))
  end

  def hash_array(pages)
    # catch
    abort "There are no pages in '#{@page_dir}'".magenta if pages.empty?
    abort "There are no fields for #{@name}.".magenta if @fields.empty?
    puts "Loading #{pages.length} pages from #{@page_dir}"
    # index each page in collection
    page_hashes = []
    pages.each { |page| page_hashes << page_hash(page) }
    page_hashes
  end

  def page_hash(page)
    yaml = YAML.load_file(page)
    hash = {
      'link' => "{{'#{yaml.fetch('permalink')}' | relative_url }}",
      'collection' => @name
    }
    hash['content'] = File.read(page).html_strip.remove_diacritics if @content
    @fields.each { |f| hash[f] = yaml[f].normalize }
    hash
  end
end
