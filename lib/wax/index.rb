# document
class Index
  attr_accessor :collections

  def initialize(opts = {})
    @s_conf       = opts.fetch(:site_config, WaxTasks.site_config)
    @collections  = collections_to_index
    @fields       = total_fields
    @path         = opts.fetch(:path, 'js/lunr-index.json')
    @ui           = opts.fetch(:ui, ui)
  end

  def collections_to_index
    to_index = @s_conf[:collections].find_all { |c| c[1].key?('lunr_index') }
    to_index.map! { |c| c[0] }
    Error.no_collections_to_index if to_index.nil?
    lunr_collections = []
    to_index.each { |c| lunr_collections << LunrCollection.new(c) }
    lunr_collections
  end

  def total_fields
    total_fields = ['pid']
    @collections.each { |c| total_fields.concat(c.fields) unless c.fields.nil? }
    total_fields.uniq
  end

  def write
    docs = []
    @collections.each { |c| docs.concat(c.data) }
    docs = add_lunr_ids(docs)
    FileUtils.mkdir_p(File.dirname(@path))
    index = "---\nlayout: none\n---\n#{JSON.pretty_generate(docs)}"
    File.open(@path, 'w') { |f| f.write(index) }
    Message.writing_index(@path)
    write_ui if @ui
  end

  def ui
    ui = "$.getJSON(\"{{ site.baseurl }}/js/lunr-index.json\", function(index_json) {\nwindow.index = new elasticlunr.Index;\nwindow.store = index_json;\nindex.saveDocument(false);\nindex.setRef('lunr_id');"
    @fields.each { |f| ui += "\nindex.addField('#{f}');" }
    ui += "\n// add docs\nfor (i in store){index.addDoc(store[i]);}"
    ui += "\n$('input#search').on('keyup', function() {\nvar results_div = $('#results');\nvar query = $(this).val();\nvar results = index.search(query, { boolean: 'AND', expand: true });\nresults_div.empty();\nif (results.length > 10) {\nresults_div.prepend(\"<p><small>Displaying 10 of \" + results.length + \" results.</small></p>\");\n}\nfor (var r in results.slice(0, 9)) {\nvar ref = results[r].ref;\nvar item = store[ref];"
    @fields.each { |f| ui += "var #{f} = item.#{f};\n" }
    ui += "var result = '<div class=\"result\"><b><a href=\"' + item.link + '\">' + title + '</a></b></p></div>';\nresults_div.append(result);\n}\n});\n});"
    ui
  end

  def write_ui
    ui = "---\nlayout: none\n---\n#{@ui}"
    path = 'js/lunr-ui.js'
    if File.exist?(path)
      Message.ui_exists(path)
    else
      File.open(path, 'w') { |file| file.write(ui) }
      Message.writing_ui(path)
    end
  end

  def add_lunr_ids(documents)
    count = 0
    docs_with_ids = []
    documents.each do |d|
      d['lunr_id'] = count
      docs_with_ids << d
      count += 1
    end
    docs_with_ids
  end
end
