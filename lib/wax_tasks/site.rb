# frozen_string_literal: true

#
module WaxTasks
  #
  class Site
    attr_reader :config

    @@image_derivative_directory = 'img/derivatives'
    @@default_config = Hashie::Mash.new(
      collections_dir: '',
      collections: {},
      search: {}
    )

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
      config.deep_merge!(@@default_config)
      config.source = Utils.safe_join(Dir.pwd, config.source)
      config.ext = permalink_extension(config)
      config
    end

    def collections
      @config.collections.each.map do |k, v|
        WaxTasks::Collection.new(k, v, @config)
      end
    end

    def find_collection(name)
      collection = @collections.find { |c| c.name == name }
      raise WaxTasks::Error::InvalidCollection, "Cannot find requested collection '#{name}'" if collection.nil?

      collection
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
      result     = 0
      collection = find_collection(collection_name)
      raise WaxTasks::Error::InvalidCollection if collection.nil?

      collection.records_from_metadata.each do |r|
        result += r.write_to_page(collection.page_source)
      end

      puts Rainbow("#{result} pages were generated to #{collection.page_source}.").cyan
      puts Rainbow("\nDone ✔").green
    end

    #
    #
    def generate_static_search
      raise WaxTasks::Error::InvalidConfig if @config.search.empty?

      @config.search.each do |name, hash|
        raise WaxTasks::NoSearchCollections unless hash.collections

        collections = hash.collections.map do |name, conf|
          find_collection(name).tap { |c| c.search_fields = conf }
        end

        index = WaxTasks::Index.new(name, hash, collections)
        puts Rainbow("Generating #{name} search index to #{index.path}").cyan
        index.write_to(@config.source_dir)
      end

      puts Rainbow("\nDone ✔").green
    end
    #
    #
    #
    def generate_simple_derivatives(collection_name)
      collection = @collections.find { |c| c.name == collection_name.to_s }
      raise WaxTasks::Error::InvalidCollection if collection.nil?

      output_dir  = Utils.safe_join(config.source, @@image_derivative_directory)
      items       = collection.items_from_imagedata
      derivatives = items.map(&:simple_derivatives).flatten

      derivatives.each do |d|
        path = "#{output_dir}/#{d.path}"
        FileUtils.mkdir_p(File.dirname(path))
        d.img.write(path)
      end

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
