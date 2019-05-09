# frozen_string_literal: true

module WaxTasks
  #
  class Site
    attr_reader :config, :title, :url, :baseurl,
                :collections, :search

    def initialize(config = nil)
      @config          = config || YAML.load_file(DEFAULT_CONFIG)
      @title           = @config.dig('title')
      @url             = @config.dig('url')
      @baseurl         = @config.dig('baseurl')
      @collections     = collections
      @search          = search

    # rescue StandardError => e
    #   raise Error::InvalidSiteConfig, "Could not load _config.yml. => #{e}"
    end

    # Contructs permalink extension from site `permalink` variable
    #
    # @return [String] the end of the permalink, either '/' or '.html'
    def ext
      case @config.dig('permalink')
      when 'pretty' || '/'
        '/'
      else
        '.html'
      end
    end

    #
    #
    def source_dir
      @config.fetch('source', Dir.pwd)
    end

    #
    #
    def collections_dir
      @config.dig('collections_dir')
    end

    #
    #
    def collections
      @config.fetch('collections', {}).map do |k, v|
        WaxTasks::Collection.new(k, v, source_dir, collections_dir, ext)
      end
    end

    #
    #
    def search
      @config.fetch('search', {}).each do |_name, conf|
        conf['collections'] = conf.dig('collections').map do |k, v|
          c = @collections.find { |c| c.name == k }
          c.content = v.fetch('content', false)
          c.search_fields = v.fetch('search_fields', [])
          c
        end
      end
    end


    #
    #
    def generate_pages(name)
      total      = 0
      collection = @collections.find { |c| c.name == name }
      metadata   = collection.metadata
      target_dir = collection.page_dir

      FileUtils.mkdir_p target_dir

      metadata.each_with_index do |record, i|
        record.order      = Utils.padded_int i, metadata.length
        record.layout     = collection.layout unless collection.layout.nil?
        record.collection = collection.name
        total += record.write_to_page(target_dir)
      end

      puts Rainbow("#{total} pages were generated to #{target_dir}.\n#{collection.metadata.length - total} pages were skipped.").cyan
      puts Rainbow("\nDone ✔").green
    end

    #
    #
    def generate_static_search
      @search.each do |name, config|
        index = Index.new(name, config)
        # index.write_to(source_dir)
        puts Rainbow("Generated #{name} search index to #{index.path}").cyan
      end
      puts Rainbow("\nDone ✔").green
    end
  end
end
