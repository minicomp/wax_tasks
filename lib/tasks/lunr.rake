require 'json'
require 'yaml'
require 'colorized_string'

namespace :wax do
  desc 'build lunr search index'
  task :lunr => :config do
    meta = $config['lunr']['meta']
    total_fields = []
    count = 0
    front_matter = '---\nlayout: null\n---'
    store_string = '\nvar store = ['
    index_string = '\nvar index = new elasticlunr.Index;\nindex.setRef(\'lunr_id\');\nindex.saveDocument(false);'
    if $config['lunr']['multi-language'].to_s == 'true'
      index_string += '\nindex.pipeline.remove(elasticlunr.trimmer);' # remove elasticlunr.trimmer if multilanguage is true
    end
    if meta.to_s.empty?
      puts('Lunr index parameters are not properly cofigured.').magenta
      exit 1
    else
      meta.each { |group| total_fields += group['fields'] }
      if total_fields.uniq.empty?
        puts('Fields are not properly configured.').magenta
        exit 1
      else
        total_fields.uniq.each { |f| index_string += '\nindex.addField(' + '\'' + f + '\'' + '); ' }
        meta.each do |collection|
          dir = collection['dir']
          fields = collection['fields']
          puts('Loading pages from ' + dir).cyan
          Dir.glob(dir + '/*').each do |md|
            begin
              yaml = YAML.load_file(md)
              hash = {}
              hash['lunr_id'] = count
              hash['link'] = '{{ site.baseurl }}' + yaml['permalink']
              fields.each { |f| hash[f] = clean(yaml[f].to_s) }
              if $config['lunr']['content']
                hash['content'] = clean(File.read(md))
              end
              index_string += '\nindex.addDoc(' + hash.to_json + '); '
              store_string += '\n' + hash.to_json + ', '
              count += 1
            rescue StandardError
              puts('Cannot load data from markdown pages in ' + dir + '.').magenta
              exit 1
            end
          end
        end
        store_string = store_string.chomp(', ') + '];'
        Dir.mkdir('js') unless File.exist?('js')
        File.open('js/lunr-index.js', 'w') { |file| file.write(front_matter + index_string + store_string) }
        puts('Writing lunr index to ' + 'js/lunr-index.js').green
      end
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
