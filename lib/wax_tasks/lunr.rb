include FileUtils

class Lunr
  def initialize(config)
    @lunr_collections = collections_to_index(config['collections'])
    @total_fields     = total_fields(@lunr_collections)
    @lunr_language    = config['lunr_language']
    @collections_dir  = config['collections_dir'].nil? ? '' : config.fetch('collections_dir') + '/'
  end

  def collections_to_index(collections)
    collections.find_all { |c| c[1].key?('lunr_index') && c[1]['lunr_index'].key?('fields') }
  end

  def total_fields(collections)
    total_fields = ['pid']
    collections.each do |c|
      total_fields = total_fields.concat(c[1]['lunr_index']['fields'])
      total_fields << 'content' if c[1]['lunr_index']['content']
    end
    total_fields.uniq
  end

  def index
    full_index = []
    count = 0
    # catch
    abort("There are no valid collections to index.".magenta) if @lunr_collections.nil?
    # index each lunr_collection
    @lunr_collections.each do |c|
      c_dir = @collections_dir + '_' + c[0]
      c_fields = c[1]['lunr_index']['fields'].uniq
      c_pages = Dir.glob(c_dir + '/*.md')
      # catch
      abort "There are no markdown pages in directory '#{c_dir}'".magenta if c_pages.empty?
      abort "There are no fields specified for #{c[0]}.".magenta if c_fields.empty?
      puts "Loading #{c_pages.length} pages from #{c_dir}"
      # index each page in collection
      c_pages.each do |page|
        yaml = YAML.load_file(page)
        hash = {
          'lunr_id' => count,
          'link' => "{{'" + yaml.fetch('permalink') + "' | relative_url }}"
        }
        c_fields.each { |f| hash[f] = rm_diacritics(thing2string(yaml[f])) }
        hash['content'] = rm_diacritics(clean(File.read(page))) if c[1]['lunr_index']['content']
        count += 1
        full_index << hash
      end
    end
    JSON.pretty_generate(full_index)
  end

  def ui
    # set up index
    ui_string = "$.getJSON(\"{{ site.baseurl }}/js/lunr-index.json\", function(index_json) {\nwindow.index = new elasticlunr.Index;\nwindow.store = index_json;\nindex.saveDocument(false);\nindex.setRef('lunr_id');"
    # add fields to index
    @total_fields.each{ |field| ui_string += "\nindex.addField('#{field}');"}
    # add docs
    ui_string += "\n// add docs\nfor (i in store){index.addDoc(store[i]);}"
    # gui
    ui_string += "\n$('input#search').on('keyup', function() {\nvar results_div = $('#results');\nvar query = $(this).val();\nvar results = index.search(query, { boolean: 'AND', expand: true });\nresults_div.empty();\nif (results.length > 10) {\nresults_div.prepend(\"<p><small>Displaying 10 of \" + results.length + \" results.</small></p>\");\n}\nfor (var r in results.slice(0, 9)) {\nvar ref = results[r].ref;\nvar item = store[ref];"
    # add fields as display vars
    @total_fields.each { |field| ui_string += "var #{field} = item.#{field};\n" }
    ui_string += "var result = '<div class=\"result\"><b><a href=\"' + item.link + '\">' + title + '</a></b></p></div>';\nresults_div.append(result);\n}\n});\n});"
    ui_string
  end
end
