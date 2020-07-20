# frozen_string_literal: true

module WaxTasks
  #
  class Config
    attr_reader :collections

    def initialize(config)
      @config         = config
      @collections    = process_collections
    end

    def self
      @config
    end

    #
    #
    def source
      @config.dig 'source'
    end

    #
    #
    def collections_dir
      @config.dig 'collections_dir'
    end

    #
    # Contructs permalink extension from site `permalink` variable
    #
    # @return [String] the end of the permalink, either '/' or '.html'
    def ext
      case @config.dig 'permalink'
      when 'pretty' || '/'
        '/'
      else
        '.html'
      end
    end

    #
    #
    def process_collections
      if @config.key? 'collections'
        @config['collections'].map do |k, v|
          WaxTasks::Collection.new(k, v, source, collections_dir, ext)
        end
      else
        []
      end
    end

    #
    #
    def search(name)
      search_config = @config.dig 'search', name
      raise WaxTasks::Error::InvalidConfig if search_config.nil?
      raise WaxTasks::Error::InvalidConfig unless search_config.dig('collections').is_a? Hash

      search_config['collections'] = search_config['collections'].map do |k, v|
        fields = v.fetch('fields', [])
        fields << 'content' if v.fetch('content', false)
        find_collection(k).tap { |c| c.search_fields = fields }
      end

      search_config
    end

    #
    #
    def find_collection(name)
      collection = @collections.find { |c| c.name == name }
      raise WaxTasks::Error::InvalidCollection, "Cannot find requested collection '#{name}'" if collection.nil?

      collection
    end
  end
end
