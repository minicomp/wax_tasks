# frozen_string_literal: true

module WaxTasks
  #
  class Site
    def initialize(config = nil)
      @config           = config || YAML.load_file(DEFAULT_CONFIG)
      @title            = title
      @url              = url
      @baseurl          = baseurl
      @source           = source
      @collections_dir  = collections_dir
      @collections      = collections
      @search           = search
    rescue StandardError => e
      raise Error::InvalidSiteConfig, "Could not load _config.yml. => #{e}"
    end

    def title
      @title || @config.dig('title')
    end

    def url
      @url || @config.dig('url')
    end

    def baseurl
      @baseurl || @config.dig('baseurl')
    end

    def source
      @source || @config.fetch('source', Dir.pwd)
    end

    def collections_dir
      @collections_dir || @config.dig('collections_dir')
    end

    def collections
      @collections || @config.fetch('collections', {})
    end

    def search
      @search || @config.fetch('search', {})
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
  end
end
