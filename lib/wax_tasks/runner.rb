# frozen_string_literal: true

#
module WaxTasks
  #
  class Runner
    attr_reader :config
    #
    #
    def initialize(config = nil)
      @config      = Hashie::Mash.new(config || YAML.load_file(DEFAULT_CONFIG))
      @collections = collections
    end

    def collections
      if @config.collections?
        @config.collections.each.map do |k, v|
          WaxTasks::Collection.new(k, v, @config)
        end
      else
        []
      end
    end

    #
    # #
    # #
    # def collections
    #   @config.collections.each.map do |k, v|
    #     WaxTasks::Collection.new(k, v, core_fields)
    #   end
    # end
    #
    # #
    # #
    # def search
    #   @config.search.each do |_name, hash|
    #     hash['collections'] = hash.dig('collections').map do |k, v|
    #       collection = @collections.find { |c| c.name == k }
    #       fields = DEFAULT_SEARCH_FIELDS + v.dig('fields')
    #       fields.push('content') if v.dig('content')
    #       collection.search_fields = fields.compact.uniq
    #       collection
    #     end
    #   end
    # end
    #
    # Contructs permalink extension from site `permalink` variable
    #
    # @return [String] the end of the permalink, either '/' or '.html'
    def ext
      case @config.permalink
      when 'pretty' || '/'
        '/'
      else
        '.html'
      end
    end

    #
    #
    def generate_pages(name)
      collection = @collections.find { |c| c.name == name }

      raise WaxTasks::Error::InvalidCollection if collection.nil?

      records    = collection.metadata_records
      result     = collection.generate_pages(records)

      puts Rainbow("#{result} pages were generated to #{collection.page_dir}.\n#{records.length - result} pages were skipped.").cyan
      puts Rainbow("\nDone ✔").green
    end
    #
    # #
    # #
    # def generate_static_search
    #   @search.each do |name, config|
    #     index = Index.new(name, config)
    #     puts Rainbow("Generating #{name} search index to #{index.path}").cyan
    #     index.write_to(source_dir)
    #   end
    #   puts Rainbow("\nDone ✔").green
    # end
    #
    # #
    # #
    # #
    # def generate_simple_derivatives(collection_name)
    #   collection = @collections.find { |c| c.name == collection_name }
    #   collection.items.each(&:build_simple_derivatives)
    #
    #   puts Rainbow("\nDone ✔").green
    # end
    #
    # #
    # #
    # #
    # def generate_iiif_derivatives(collection_name)
    #   puts collection_name
    # end
  end
end
