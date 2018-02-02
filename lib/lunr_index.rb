require 'yaml'
require 'colorized_string'
require 'helpers'

# LunrIndex class
class LunrIndex
  attr_reader :output

  def initialize(collections, lunr_language)
    @collections      = collections
    @lunr_language    = lunr_language
    @lunr_collections = []
    @total_fields     = []
    @output           = ''

    pre_process
    add_docs
  end

  def pre_process
    @output += "\nvar index = new elasticlunr.Index;\nindex.setRef('lunr_id');\nindex.saveDocument(false);"
    @output += "\nindex.pipeline.remove(elasticlunr.trimmer);" if @lunr_language
    @collections.each do |c|
      if c[1].key?('lunr_index') && c[1]['lunr_index'].key?('fields')
        @total_fields.concat c[1]['lunr_index']['fields']
        @total_fields << 'content' if c[1]['lunr_index']['content']
        @lunr_collections << c
      end
    end
    @total_fields.uniq!
    raise "Fields are not properly configured.".magenta if @total_fields.empty?
    @total_fields.each { |f| @output += "\nindex.addField(" + "'" + f + "'" + "); " }
  end

  def add_docs
    count = 0
    index_string = @output
    store_string = "\nvar store = ["

    @collections.each do |c|
      collection = c[1]
      dir = '_' + collection['directory'].gsub(/^_?/, '') || '_' + c[0]
      fields = collection['lunr_index']['fields']
      pages = Dir.glob(dir + '/*.md')

      raise "There are no markdown pages in directory '#{dir}'".magenta if pages.nil?
      raise "There are no fields specified for #{c[0]}. Continuing.".magenta if fields.nil?

      puts "Loading #{pages.length} pages from #{dir}"
      pages.each do |page|
        begin
          yaml = YAML.load_file(page)
          hash = { 'lunr_id' => count, 'link' => '{{ site.baseurl }}' + yaml['permalink'] }
          fields.uniq.each { |f| hash[f] = yaml[f].to_s }
          hash['content'] = clean(File.read(page)) if collection['lunr_index']['content']
          index_string += "\nindex.addDoc(" + hash.to_json + "); "
          store_string += "\n" + hash.to_json + ", "
          count += 1
        rescue StandardError
          puts "Cannot load data from markdown pages in #{dir}.".magenta
          exit 1
        end
      end
    end

    store_string += store_string.chomp(', ') + '];'
    @output = index_string + store_string
  end
end
