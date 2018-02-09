include FileUtils

# initializes a lunr index to be output to js/lunr-index.js
class Index
  attr_reader :output

  def initialize(collections, lunr_language)
    @collections      = collections
    @lunr_language    = lunr_language
    @cdir             = $config['collections_dir'].nil? ? '' : $config.fetch('collections_dir') + '/'
    @lunr_collections = []
    @total_fields     = []
    @output           = ''

    pre_process
    add_docs
  end

  def pre_process
    @output += "---\nlayout: none\n---\nvar index = new elasticlunr.Index;\nindex.setRef('lunr_id');\nindex.saveDocument(false);"
    @output += "\nindex.pipeline.remove(elasticlunr.trimmer);" if @lunr_language
    @collections.each do |c|
      if c[1].key?('lunr_index') && c[1]['lunr_index'].key?('fields')
        @total_fields.concat c[1]['lunr_index']['fields']
        @total_fields << 'content' if c[1]['lunr_index']['content']
        @lunr_collections << c
      end
    end
    @total_fields.uniq!
    abort("Fields are not properly configured.".magenta) if @total_fields.empty?
    @total_fields.each { |f| @output += "\nindex.addField(" + "'" + f + "'" + "); " }
  end

  def add_docs
    count = 0
    store_string = "\nvar store = ["

    abort("There are no valid collections to index.".magenta) if @collections.nil?
    @lunr_collections.each do |c|
      dir = @cdir + '_' + c[0]
      fields = c[1]['lunr_index']['fields'].uniq
      pages = Dir.glob(dir + '/*.md')

      abort "There are no markdown pages in directory '#{dir}'".magenta if pages.empty?
      abort "There are no fields specified for #{c[0]}.".magenta if fields.empty?

      puts "Loading #{pages.length} pages from #{dir}"
      pages.each do |page|
        begin
          yaml = YAML.load_file(page)
          hash = {
            'lunr_id' => count,
            'link' => "{{'" + yaml.fetch('permalink') + "' | relative_url }}"
          }
          fields.each { |f| hash[f] = rm_diacritics(yaml[f].to_s) }
          hash['content'] = rm_diacritics(clean(File.read(page))) if c[1]['lunr_index']['content']
          @output += "\nindex.addDoc(" + hash.to_json + "); "
          store_string += "\n" + hash.to_json + ", "
          count += 1
        rescue StandardError
          abort "Cannot load data from markdown pages in #{dir}.".magenta
        end
      end
    end
    @output += store_string.chomp(', ') + '];'
  end
end
