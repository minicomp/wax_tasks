# frozen_string_literal: true

module WaxTasks
  #
  class Config
    attr_reader :collections

    def initialize(config)
      @config           = config
      @collections      = process_collections
    end

    def source
      Utils.safe_join(Dir.pwd, @config.dig('source'))
    end

    def collections_dir
      @config.dig('collections_dir')
    end

    #
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

    # def method_missing(method_name, *args)
    #   str = method_name.to_s
    #   if str.end_with? '='
    #     @config[str.chomp('=')] = *args
    #   else
    #     @config.dig(str)
    #   end
    # end
    #
    # def respond_to_missing?(method_name, include_private = false)
    #   method_name.to_s || super
    # end

    def process_collections
      if @config.key? 'collections'
        @config['collections'].map do |k, v|
          WaxTasks::Collection.new(k, v, source, collections_dir, ext)
        end
      else
        []
      end
    end

    def search(name)
      search_config = @config.dig('search', name)
      raise WaxTasks::Error::InvalidConfig if search_config.nil?
      raise WaxTasks::Error::InvalidConfig unless search_config.dig('collections').is_a? Hash

      search_config['collections'] = search_config['collections'].map do |k, v|
        fields = v.fetch('fields', [])
        fields << 'content' if v.fetch('content', false)
        find_collection(k).tap { |c| c.search_fields = fields }
      end
      search_config
    end

    def find_collection(name)
      collection = @collections.find { |c| c.name == name }
      raise WaxTasks::Error::InvalidCollection, "Cannot find requested collection '#{name}'" if collection.nil?

      collection
    end
  end
end
