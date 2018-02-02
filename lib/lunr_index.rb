require 'json'
require 'yaml'
require 'colorized_string'
require 'helpers'

# LunrIndex class
class LunrIndex
  def initialize(lunr_collections, total_fields, lunr_language)
    @collections    = lunr_collections
    @lunr_language  = lunr_language
    @total_fields   = total_fields
    @output         = ''
  end

  def process
    if @total_fields.empty?
      puts "Fields are not properly configured.".magenta
      exit 1
    else
      index_string = "\nvar index = new elasticlunr.Index;\nindex.setRef('lunr_id');\nindex.saveDocument(false);"
      index_string += "\nindex.pipeline.remove(elasticlunr.trimmer);" if @lunr_language
      store_string = "\nvar store = ["
      count = 0

      @total_fields.each { |f| index_string += "\nindex.addField(" + "'" + f + "'" + "); " }

      @collections.each do |c|
        collection = c[1]
        dir = '_' + collection['directory'].gsub(/^_?/, '') || '_' + c[0]
        fields = collection['lunr_index']['fields']
        pages = Dir.glob(dir + '/*.md')

        if pages.nil?
          puts "There are no markdown pages in directory '#{dir}'. Continuing.".yellow
        elsif fields.nil?
          puts "There are no fields specified for #{c[0]}. Continuing.".yellow
        else
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
      end
      store_string = store_string.chomp(', ') + '];'
      @output = index_string + store_string
    end
  end

  def write_to_file
    Dir.mkdir('js') unless File.exist?('js')
    File.open('js/lunr-index.js', 'w') { |file| file.write(@output) }
    puts "Writing lunr index to js/lunr-index.js".cyan
  end
end
