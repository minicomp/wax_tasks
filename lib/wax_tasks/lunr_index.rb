# document
class LunrIndex
  attr_accessor :collections, :fields

  def initialize(collections)
    @collections  = collections
    @fields       = total_fields
  end

  def total_fields
    total_fields = ['pid']
    @collections.each { |c| total_fields.concat(c.fields) unless c.fields.nil? }
    total_fields.uniq
  end

  def to_s
    data = @collections.map(&:data).flatten
    data.each_with_index.map { |d, id| d['lunr_index'] = id }
    "---\nlayout: none\n---\n#{JSON.pretty_generate(data)}"
  end

  def default_ui
    <<~HEREDOC
      ---
      layout: none
      ---
      $.getJSON({{ site.baseurl }}/js/lunr-index.json, function(index_json) {
        window.index = new elasticlunr.Index;
        window.store = index_json;
        index.saveDocument(false);
        index.setRef('lunr_id');
        #{@fields.map { |f| "index.addField('#{f}');" }.join("\n")}
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
            #{@fields.map { |f| "var #{f} = item.#{f};" }.join("\n")}
            var result = '<div class="result"><b><a href="' + item.link + '">' + title + '</a></b></p></div>';
            results_div.append(result);
          }
        });
      });
    HEREDOC
  end
end
