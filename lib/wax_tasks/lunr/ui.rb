# document
class UI
  def initialize(index)
    @site_config  = index.site_config
    @fields       = index.fields
    @ui           = generate_ui

    write_ui
  end

  def generate_ui
    <<~HEREDOC
      ---
      layout: none
      ---
      $.getJSON({{ site.baseurl }}/js/lunr-index.json, function(index_json) {
        window.index = new elasticlunr.Index;
        window.store = index_json;
        index.saveDocument(false);
        index.setRef('lunr_id');
        #{add_fields}
        // add docs
        for (i in store){
          index.addDoc(store[i]);
        }
        $('input#search').on('keyup', function() {
          var results_div = $('#results');
          var query = $(this).val();
          var results = index.search(query, { boolean: 'AND', expand: true });
          results_div.empty();
          if (results.length > 10) {
            results_div.prepend("<p><small>Displaying 10 of " + results.length + " results.</small></p>");
          }
          for (var r in results.slice(0, 9)) {
            var ref = results[r].ref;
            var item = store[ref];
            #{results}
            var result = '<div class="result"><b><a href="' + item.link + '">' + title + '</a></b></p></div>';
            results_div.append(result);
          }
        });
      });
    HEREDOC
  end

  def construct_path(path)
    [@site_config[:source_dir], path].compact.join('/')
  end

  def add_fields
    @fields.map { |f| "index.addField('#{f}');" }.join("\n")
  end

  def results
    @fields.map { |f| "var #{f} = item.#{f};" }.join("\n")
  end

  def write_ui
    path = construct_path('js/lunr-ui.js')
    if File.exist?(path)
      # Message.ui_exists(path)
    else
      File.open(path, 'w') { |file| file.write(@ui) }
      # Message.writing_ui(path)
    end
  end
end
