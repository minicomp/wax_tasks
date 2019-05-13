# frozen_string_literal: true

#
module WaxTasks
  #
  class Site
    attr_reader :config

    DEFAULT_CONFIG = Hashie::Mash.new(
      source: Dir.pwd,
      collections_dir: '',
      collections: {},
      search: {}
    ).freeze

    #
    #
    def initialize(config)
      @config      = mash(config)
      @collections = collections
    end

    #
    #
    def mash(config)
      config = Hashie::Mash.new(config)
      config.deep_merge!(DEFAULT_CONFIG)
      config.ext = permalink_extension(config)
      config
    end

    #
    #
    def source=(source)
      @config.source = source
    end

    #
    #
    def collections
      @config.collections.each.map do |k, v|
        WaxTasks::Collection.new(k, v, @config)
      end
    end

    #
    # Contructs permalink extension from site `permalink` variable
    #
    # @return [String] the end of the permalink, either '/' or '.html'
    def permalink_extension(config)
      case config.permalink
      when 'pretty' || '/'
        '/'
      else
        '.html'
      end
    end

    #
    #
    def generate_pages(collection_name)
      collection = @collections.find { |c| c.name == collection_name.to_s }
      raise WaxTasks::Error::InvalidCollection if collection.nil?

      result = collection.generate_pages

      puts Rainbow("#{result} pages were generated to #{collection.page_dir}.").cyan
      puts Rainbow("\nDone ✔").green
    end

    #
    #
    def generate_static_search
      raise WaxTasks::Error::InvalidSiteConfig if @config.search.empty?

      @config.search.each do |name, hash|
        path                  = hash.index_file
        collections           = search_collections(hash.collections)
        index                 = WaxTasks::Index.new(name, path, collections)

        puts Rainbow("Generating #{name} search index to #{index.path}").cyan
        index.write_to(@config.source_dir)
      end

      puts Rainbow("\nDone ✔").green
    end

    #
    #
    def search_collections(search_collections_config)
      raise WaxTasks::NoSearchCollections if search_collections_config.nil?

      search_collections_config.map do |name, hash|
        collection = @collections.find { |c| c.name == name }
        raise WaxTasks::Error::InvalidCollection if collection.nil?

        fields = DEFAULT_SEARCH_FIELDS + hash.fields
        fields.push('content') if hash.content
        collection.search_fields = fields.compact.uniq
        collection
      end
    end

    #
    #
    #
    def generate_simple_derivatives(collection_name)
      collection = @collections.find { |c| c.name == collection_name.to_s }
      raise WaxTasks::Error::InvalidCollection if collection.nil?

      collection.items.each(&:build_simple_derivatives)

      puts Rainbow("\nDone ✔").green
    end

    #
    #
    #
    def generate_iiif_derivatives(collection_name)
      # TO DO
      puts collection_name
    end
  end
end
