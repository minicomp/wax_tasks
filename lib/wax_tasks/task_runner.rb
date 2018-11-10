module WaxTasks
  # Class for running the Rake tasks in ./tasks
  # TaskRunner is responsible for loading and parsing the site config
  # from `_config.yml`, which can be overridden with .override(opts)
  #
  # @attr site [Hash] main variables from site config normalized + symbolized
  class TaskRunner
    attr_reader :site

    # Creates a new TaskRunner with a config hash or default config file
    #
    # @param env    [String]  test/prod. only affects Branch module
    # @param config [Hash]    optional hash, should mirror a parsed _config.yml
    # @example give a custom config
    #   config = {
    #     title:        'custom title',
    #     url:          'custom.url',
    #     collections:  {...}
    #   }
    #   WaxTasks::TaskRunner.new(config)
    # @example use default config from file
    #   WaxTasks::TaskRunner.new
    def initialize(config = {}, env = 'prod')
      @config = YAML.load_file(DEFAULT_CONFIG).symbolize_keys if config.empty?
      @site = {
        env:              env,
        title:            @config.dig(:title),
        url:              @config.dig(:url),
        baseurl:          @config.dig(:baseurl),
        repo_name:        @config.dig(:repo_name),
        source_dir:       @config.dig(:source),
        collections_dir:  @config.dig(:collections_dir),
        collections:      @config.dig(:collections),
        lunr:             @config.dig(:lunr),
        js:               @config.dig(:js),
        permalink:        Utils.construct_permalink(@config)
      }
    rescue StandardError => e
      raise Error::InvalidSiteConfig, "Could not load _config.yml. => #{e}"
    end

    # Overrides a specific part of @site
    #
    # @param opts [Hash] part of the site config to be overwritten
    # @example override title + url
    #   runner = WaxTasks::TaskRunner.new
    #   runner.override({ title: 'my new title', url: 'my-new.url' })
    def override(opts)
      opts.each { |k, v| @site[k] = v }
      @site[:permalink] = Utils.construct_permalink(opts)
      self
    end

    # Given an array of command line arguments `args`,
    # creates a PagemasterCollection for each and generates markdown
    # pages from its specified data `source` file
    #
    # @param args [Array] the arguments/collection names from wax:pagemaster
    # @return [Nil]
    def pagemaster(args)
      args.each do |name|
        PagemasterCollection.new(name, @site).generate_pages
      end
    end

    # Creates a LunrCollection for each collection
    # that has lunr_index parameters in the site config
    # and generates a lunr-index.json file from the collection data
    #
    # @param generate_ui [Boolean] whether/not to generate a default lunr UI
    # @return [Nil]
    def lunr(generate_ui: false)
      indexes = @site[:lunr]&.dig('index')
      indexes.each do |index|
        file = index.fetch('file', LUNR_INDEX_PATH)
        lunr_collections = index.dig('collections')

        raise Error::NoLunrCollections, 'No collections to index were specified in _config.yml' if lunr_collections.nil?

        lunr_collections.map! { |name| LunrCollection.new(name, @site) }

        index_path = Utils.root_path(@site[:source_dir], file)
        index = LunrIndex.new(lunr_collections, index_path)
        FileUtils.mkdir_p(File.dirname(index_path))
        File.open(index_path, 'w') { |f| f.write(index) }
        puts "Writing lunr search index to #{index_path}.".cyan

        next unless generate_ui
        ui_path = Utils.root_path(@site[:source_dir], LUNR_UI_PATH)
        puts "Writing default lunr UI to #{ui_path}.".cyan
        File.open(ui_path, 'w') { |f| f.write(index.default_ui) }
      end
    end

    # Given an array of command line arguments `args`,
    # creates a IiifCollection for each and generates iiif
    # derivative images, manifests, etc. from source image files
    #
    # @param args [Array] the arguments/collection names from wax:pagemaster
    # @return [Nil]
    def derivatives_iiif(args)
      args.each do |name|
        iiif_collection = ImageCollection.new(name, @site)
        iiif_collection.build_iiif_derivatives
      end
    end

    # @return [Nil]
    def derivatives_simple(args)
      args.each do |name|
        image_collection = ImageCollection.new(name, @site)
        image_collection.build_simple_derivatives
      end
    end

    # Finds the JS dependencies listed in site config and
    # writes them to a package.json file
    # in orderto easily track / monitor / update them
    #
    # @return [Nil]
    def js_package
      names = []
      package = {
        'name'          => site[:title],
        'version'       => @config.fetch(:version, ''),
        'dependencies'  => {}
      }
      site[:js].each do |dependency|
        name = dependency[0]
        names << name
        version = dependency[1]['version']
        package['dependencies'][name] = '^' + version
      end
      package
    end

    # Constructs a TravisBranch or LocalBranch object
    # with appropriate Git credentials and pushes
    # the compiled Jekyll site to the target GitHub branch
    #
    # @param target [String] the name of the Git branch to deploy to
    # @return [Nil]
    def push_branch(target)
      if ENV.fetch('CI', false)
        TravisBranch.new(self.site, target).push
      else
        LocalBranch.new(self.site, target).push
      end
    end
  end
end
