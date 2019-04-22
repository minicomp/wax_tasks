module WaxTasks
  class Site

    def initialize(config = nil)
      @config           = config || YAML.load_file(DEFAULT_CONFIG)
      @title            = title
      @url              = url
      @baseurl          = baseurl
      @source           = source
      @collections_dir  = collections_dir
      @collections      = collections
      @lunr_index       = lunr_index
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

    def lunr_index
      @lunr_index || @config.fetch('lunr_index', {})
    end
  end
end
