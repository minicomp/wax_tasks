require_relative 'page_set'

module WaxTasks
  module Lunr
    # A Lunr::Index document that combines data from all collections
    # in site config that have `lunr_index` parameters.
    #
    # @attr collections [Array] a list of LunrCollection objects
    # @attr fields [Array] shared list of fields to index among LunrCollections
    class Index
      attr_reader :collections, :index_path, :fields

      # Creates a new LunrIndex object
      def initialize(site, index_path, collections)
        raise Error::NoLunrCollections, 'No collections were configured to index' if collections.nil?
        raise Error::NoLunrCollections, 'No path was given for index file' if index_path.nil?

        @collections = collections.keys.map! do |c|
          Lunr::PageSet.new(c, collections[c], site)
        end

        @index_path = index_path
        @fields     = self.total_fields
      end

      # @return [Array] shared list of fields to index among indexed collections
      def total_fields
        @collections.map { |c| c.data.map(&:keys) }.flatten.uniq
      end

      # @return [String] writes index as pretty JSON with YAML front-matter
      def to_s
        data = @collections.map(&:data).flatten
        data.each_with_index.map { |m, id| m['lunr_index'] = id }
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
          $.getJSON("{{ '#{@index_path}' | absolute_url }}", function(index_json) {
            window.index = new elasticlunr.Index;
            window.store = index_json;
            index.saveDocument(false);
            index.setRef('lunr_index');
            #{@fields.map { |f| "index.addField('#{f}');" }.join("\n\t")}
            // add docs
            for (i in store){
              index.addDoc(store[i]);
            }
            $('input#search').on('keyup', function() {
              var results_div = $('#results');
              var query = $(this).val();
              var results = index.search(query, { boolean: 'AND', expand: true });
              results_div.empty();
              for (var r in results) {
                var ref = results[r].ref;
                var item = store[ref];
                var pid = item.pid;
                var label = item.label;
                var meta = `#{@fields.except(%w[pid label]).take(3).map { |f| "${item.#{f}}" }.join(' | ')}`;
                if ('thumbnail' in item) {
                  var thumb = `<img class='sq-thumb-sm' src='{{ "" | absolute_url }}${item.thumbnail}'/>&nbsp;&nbsp;&nbsp;`
                }
                else {
                  var thumb = '';
                }
                var result = `<div class="result"><a href="${item.link}">${thumb}<p><span class="title">${item.label}</span><br>${meta}</p></a></p></div>`;
                results_div.append(result);
              }
            });
          });
        HEREDOC
      end
    end
  end
end
