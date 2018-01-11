require 'json'
require 'yaml'
require 'iiif_s3'
require 'colorized_string'

namespace :wax do
  desc 'build lunr search index'
  task :lunr => :config do

    meta = $config['lunr']['meta']
    name = $config['lunr']['name'].to_s

    total_fields = []
    count = 0

    front_matter = "---\nlayout: null\n---"
    index_string = "\nvar index = elasticlunr(function () {\nthis.setRef('lunr_id');"
    store_string = "\nvar store = ["
    jq_string = "\n$(document).ready(function() {\n$('input#search').on('keyup', function () {\nvar resultdiv = $('#results');\nvar query = $(this).val();\nvar result = index.search(query, {expand: true});\nresultdiv.empty();\nfor (var item in result) {\nvar ref = result[item].ref;\nvar searchitem = '<div class=\"result\"><b><a href=\"' + store[ref].link + '\" class=\"post-title\">' + store[ref].title + '</a></b><br><p>' "


    if meta.to_s.empty?
      raise "Lunr index parameters are not properly cofigured.".magenta
    else
      meta.each { |group| total_fields += group['fields'] }
      if total_fields.uniq.empty?
        raise "Fields are not properly configured.".magenta
      else
        total_fields.uniq.each do |f|
          index_string += "\nthis.addField(" + "'" + f + "'" + "); "
          unless f == "title"
            jq_string += " + store[ref]." + f + " + ' / '"
          end
        end
        index_string += "\nthis.saveDocument(false); });"

        meta.each do |collection|

          dir = collection['dir']
          perma = collection['permalink']
          fields = collection['fields']

          puts ("Loading pages from " + dir).cyan

          Dir.glob(dir+"/*").each do |md|
            begin
              yaml = YAML.load_file(md)
              hash = Hash.new
              hash['lunr_id'] = count
              hash['link'] = "{{ site.baseurl }}" + yaml['permalink']
              fields.each { |f| hash[f] = yaml[f].to_s }
              if $config['lunr']['content']
                hash['content'] = File.read(md).gsub(/\A---(.|\n)*?---/, "").gsub(/<\/?[^>]*>/, "").gsub("\\n", "").gsub('"',"'").to_s
              end
              index_string += "\nindex.addDoc(" + hash.to_json + "); "
              store_string += "\n" + hash.to_json + ", "
              count += 1
            rescue
              raise ("Cannot load data from markdown pages in " + dir + ".").magenta
            end
          end
        end

        store_string = store_string.chomp(", ") + "];"
        jq_string = jq_string.chomp(" / '") + "</p></div>';\nresultdiv.append(searchitem);}\n});\n});"

        Dir.mkdir('js') unless File.exists?('js')
        File.open("js/lunr-index.js", 'w') { |file| file.write( front_matter + index_string + store_string ) }
        puts ("Writing lunr index to " + "js/lunr-index.js").green
      end
    end
  end
end
