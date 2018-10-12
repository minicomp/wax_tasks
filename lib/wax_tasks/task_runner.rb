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
      config = YAML.load_file(DEFAULT_CONFIG).symbolize_keys if config.empty?
      @site = {
        env:              env,
        title:            config.fetch(:title, ''),
        url:              config.fetch(:url, ''),
        baseurl:          config.fetch(:baseurl, ''),
        repo_name:        config.fetch(:repo_name, ''),
        source_dir:       config.fetch(:source, nil),
        collections_dir:  config.fetch(:collections_dir, nil),
        collections:      config.fetch(:collections, {}),
        js:               config.fetch(:js, false),
        permalink:        Utils.construct_permalink(config)
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
      lunr_collections = Utils.get_lunr_collections(@site)
      lunr_collections.map! { |name| LunrCollection.new(name, @site) }

      index = LunrIndex.new(lunr_collections)
      index_path = Utils.make_path(@site[:source_dir], LUNR_INDEX_PATH)

      FileUtils.mkdir_p(File.dirname(index_path))
      File.open(index_path, 'w') { |f| f.write(index) }
      puts "Writing lunr search index to #{index_path}.".cyan

      if generate_ui
        ui_path = Utils.make_path(@site[:source_dir], LUNR_UI_PATH)
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
    def iiif(args)
      output_dir = Utils.make_path(@site[:source_dir], 'iiif')
      build_opts = {
        base_url: "{{ 'iiif' | absolute_url }}",
        output_dir: output_dir,
        variants: DEFAULT_IMAGE_VARIANTS,
        verbose: true
      }
      builder = WaxIiif::Builder.new(build_opts)

      image_records = args.map do |name|
        IiifCollection.new(name, @site).records
      end.flatten

      builder.load(image_records)
      builder.process_data

      Utils.add_yaml_front_matter(Dir["#{output_dir}/**/*.json"])
      Utils.output_iiif_list(@site, builder.manifests, image_records)
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
        'version'       => '1.0.0',
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
