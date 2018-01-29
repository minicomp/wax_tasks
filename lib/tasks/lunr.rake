require 'json'
require 'yaml'
require 'colorized_string'

namespace :wax do
  desc 'build lunr search index'
  task :lunr => :config do
    total_fields = []
    count = 0
    front_matter = "---\nlayout: null\n---"
    store_string = "\nvar store = ["
    index_string = "\nvar index = new elasticlunr.Index;\nindex.setRef('lunr_id');\nindex.saveDocument(false);"
    index_string += "\nindex.pipeline.remove(elasticlunr.trimmer);" if $config['lunr_language']
    collections = $config['collections']
    collections.each do |c|
      if c[1].key?('lunr_index') && c[1]['lunr_index'].key?('fields')
        total_fields.concat c[1]['lunr_index']['fields']
      end
    end
    if total_fields.uniq.empty?
      puts "Fields are not properly configured.".magenta
      exit 1
    else
      total_fields.uniq.each { |f| index_string += "\nindex.addField(" + "'" + f + "'" + "); " }
      collections.each do |collection|
        name = collection[0]
        collection = collection[1]
        if collection.key?('lunr_index') && collection['lunr_index'].key?('fields')
          dir = collection['directory'] || '_' + name
          fields = collection['lunr_index']['fields']
          puts "Loading pages from #{dir}".cyan
          Dir.glob(dir + '/*.md').each do |md|
            begin
              yaml = YAML.load_file(md)
              hash = {}
              hash['lunr_id'] = count
              hash['link'] = '{{ site.baseurl }}' + yaml['permalink']
              fields.uniq.each { |f| hash[f] = yaml[f].to_s }
              if collection['lunr_index']['content']
                hash['content'] = clean(File.read(md))
              end
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
      Dir.mkdir('js') unless File.exist?('js')
      File.open('js/lunr-index.js', 'w') { |file| file.write(front_matter + index_string + store_string) }
      puts "Writing lunr index to js/lunr-index.js".cyan
    end
  end
end

def clean(str)
  str = str.gsub(/\A---(.|\n)*?---/, '') # remove yaml front matter
  str = str.gsub(/{%(.*)%}/, '') # remove functional liquid
  str = str.gsub(/<\/?[^>]*>/, '') # remove html
  str = str.gsub('\\n', '').gsub(/\s+/, ' ') # remove newlines and extra space
  str = str.tr('"', "'").to_s # replace double quotes with single
  return str
end
