# document
class UI
  def initialize(index)
    @site_config  = index.site_config
    @fields       = index.fields
    @ui           = generate_ui

    write_ui
  end

  def generate_ui
    "#{yaml_header}\n#{load_json}\n#{add_fields}\n#{add_docs}\n#{search_docs}\n#{results}\n#{display}"
  end

  def write_ui
    path = construct_path('js/lunr-ui.js')
    if File.exist?(path)
      Message.ui_exists(path)
    else
      File.open(path, 'w') { |file| file.write(@ui) }
      Message.writing_ui(path)
    end
  end

  def construct_path(path)
    "#{@site_config[:source_dir]}/#{path}" if @site_config[:source_dir]
  end

  def yaml_header
    %(
    ---
    layout: none
    ---
    )
  end

  def load_json
    %(
    $.getJSON\({{ site.baseurl }}/js/lunr-index.json, function\(index_json\) {
    window.index = new elasticlunr.Index;
    window.store = index_json;
    index.saveDocument\(false\);
    index.setRef\('lunr_id'\);
    )
  end

  def add_fields
    str = ''
    @fields.each { |f| str += "\nindex.addField('#{f}');" }
    str
  end

  def add_docs
    %(
    // add docs
    for \(i in store\){
    index.addDoc\(store[i]\);
    }
    )
  end

  def search_docs
    %(
    $\('input#search'\).on\('keyup', function\(\) {
    var results_div = $\('#results'\);
    var query = $\(this\).val\(\);
    var results = index.search\(query, { boolean: 'AND', expand: true }\);
    results_div.empty\(\);
    if \(results.length > 10\) {
    results_div.prepend\("<p><small>Displaying 10 of " + results.length + " results.</small></p>"\);
    }
    for \(var r in results.slice\(0, 9\)\) {
    var ref = results[r].ref;
    var item = store[ref];
    )
  end

  def results
    str = ''
    @fields.each { |f| str += "var #{f} = item.#{f};\n" }
    str
  end

  def display
    %(
    var result = '<div class="result"><b><a href="' + item.link + '">' + title + '</a></b></p></div>';
    results_div.append\(result\);
    }
    }\);
    }\);
    )
  end
end
