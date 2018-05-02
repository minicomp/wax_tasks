include FileUtils
require 'json'

# module for generating elasticlunr index and default jquery ui
module Lunr
  def self.total_fields(collections)
    total_fields = ['pid']
    collections.each do |c|
      total_fields = total_fields.concat(c[1]['lunr_index']['fields'])
      total_fields << 'content' if c[1]['lunr_index']['content']
    end
    total_fields.uniq
  end

  def self.collections(site_config)
    site_config['collections'].find_all { |c| c[1].key?('lunr_index') && c[1]['lunr_index'].key?('fields') }
  end

  def self.index(cdir, collections)
    index = []
    count = 0
    abort 'There are no valid collections to index.'.magenta if collections.nil?

    collections.each do |c|
      dir = cdir + '_' + c[0]
      fields = c[1]['lunr_index']['fields'].uniq
      pages = Dir.glob(dir + '/*.md')
      get_content = c[1]['lunr_index']['content']
      # catch
      abort "There are no markdown pages in directory '#{dir}'".magenta if pages.empty?
      abort "There are no fields specified for #{c[0]}.".magenta if fields.empty?
      puts "Loading #{pages.length} pages from #{dir}"
      # index each page in collection
      pages.each do |page|
        index << page_hash(page, fields, get_content, count)
        count += 1
      end
    end
    JSON.pretty_generate(index)
  end

  def self.page_hash(page, fields, get_content, count)
    yaml = YAML.load_file(page)
    hash = {
      'lunr_id' => count,
      'link' => "{{'" + yaml.fetch('permalink') + "' | relative_url }}"
    }
    fields.each { |f| hash[f] = rm_diacritics(thing2string(yaml[f])) }
    hash['content'] = rm_diacritics(clean(File.read(page))) if get_content
    hash
  end

  def self.ui(total_fields)
    # set up index
    ui_string = "$.getJSON(\"{{ site.baseurl }}/js/lunr-index.json\", function(index_json) {\nwindow.index = new elasticlunr.Index;\nwindow.store = index_json;\nindex.saveDocument(false);\nindex.setRef('lunr_id');"
    # add fields to index
    total_fields.each { |field| ui_string += "\nindex.addField('#{field}');" }
    # add docs
    ui_string += "\n// add docs\nfor (i in store){index.addDoc(store[i]);}"
    # gui
    ui_string += "\n$('input#search').on('keyup', function() {\nvar results_div = $('#results');\nvar query = $(this).val();\nvar results = index.search(query, { boolean: 'AND', expand: true });\nresults_div.empty();\nif (results.length > 10) {\nresults_div.prepend(\"<p><small>Displaying 10 of \" + results.length + \" results.</small></p>\");\n}\nfor (var r in results.slice(0, 9)) {\nvar ref = results[r].ref;\nvar item = store[ref];"
    # add fields as display vars
    total_fields.each { |field| ui_string += "var #{field} = item.#{field};\n" }
    ui_string += "var result = '<div class=\"result\"><b><a href=\"' + item.link + '\">' + title + '</a></b></p></div>';\nresults_div.append(result);\n}\n});\n});"
    ui_string
  end

  def self.write_index(index)
    mkdir_p('js')
    index = "---\nlayout: none\n---\n" + index
    path = 'js/lunr-index.json'
    File.open(path, 'w') { |file| file.write(index) }
    puts "Writing lunr index to #{path}".cyan
  end

  def self.write_ui(ui)
    ui = "---\nlayout: none\n---\n" + ui
    path = 'js/lunr-ui.js'
    if File.exist?(path)
      puts "Lunr UI already exists at #{path}. Skipping".cyan
    else
      File.open(path, 'w') { |file| file.write(ui) }
      puts "Writing lunr ui to #{path}".cyan
    end
  end

  def self.clean(str)
    str.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
    str.gsub!(/{%(.*)%}/, '') # remove functional liquid
    str.gsub!(/<\/?[^>]*>/, '') # remove html
    str.gsub!('\\n', '') # remove newlines
    str.gsub!(/\s+/, ' ') # remove extra space
    str.tr!('"', "'") # replace double quotes with single
    str
  end

  def self.rm_diacritics(str)
    to_replace  = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž'
    replaced_by = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz'
    str.tr(to_replace, replaced_by)
  end

  def self.thing2string(thing)
    thing = thing.join(' || ') if thing.is_a?(Array)
    thing.to_s
  end
end