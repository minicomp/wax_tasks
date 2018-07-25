module WaxTasks
  # A LunrIndex document that combines data from all collections
  # in site config that have `lunr_index` parameters.
  #
  # @attr collections [Array] a list of LunrCollection objects
  # @attr fields [Array] shared list of fields to index among LunrCollections
  class LunrIndex
    attr_accessor :collections, :fields

    # Creates a new LunrIndex object
    def initialize(collections)
      @collections  = collections
      @fields       = total_fields
    end

    # @return [Array] shared list of fields to index among LunrCollections
    def total_fields
      total_fields = @collections.map(&:fields).reduce([], :concat)
      total_fields.uniq
    end

    # @return [String] writes index data as pretty JSON with YAML front-matter
    def to_s
      data = @collections.map(&:data).flatten
      data.each_with_index.map { |d, id| d['lunr_index'] = id }
      "---\nlayout: none\n---\n#{JSON.pretty_generate(data)}"
    end

    # Creates a default LunrUI / JS file for displaying the Index
    #
    # @return [String]
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
end
