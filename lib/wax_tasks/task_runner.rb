module WaxTasks
  # document
  class TaskRunner
    attr_accessor :site

    def initialize(config = {})
      config = YAML.load_file(DEFAULT_CONFIG).symbolize_keys if config.empty?

      @site = {
        title:            config.fetch(:title, ''),
        url:              config.fetch(:url, ''),
        baseurl:          config.fetch(:baseurl, ''),
        source_dir:       config.fetch(:source, nil),
        collections_dir:  config.fetch(:collections_dir, nil),
        collections:      config.fetch(:collections, {}),
        js:               config.fetch(:js, false),
        permalink:        Utils.construct_permalink(config)
      }
    rescue StandardError => e
      raise Error::InvalidSiteConfig, "Could not load _config.yml. => #{e}"
    end

    def override(opts)
      opts.each { |k, v| @site[k] = v }
      @site[:permalink] = Utils.construct_permalink(opts)
      self
    end

    def pagemaster(args)
      args.each do |name|
        PagemasterCollection.new(name, @site).generate_pages
      end
    end

    def lunr(generate_ui = false)
      lunr_collections = Utils.get_lunr_collections(@site)
      lunr_collections.map! { |name| LunrCollection.new(name, @site) }

      index = LunrIndex.new(lunr_collections)
      index_path = Utils.make_path(@site[:source_dir], LUNR_INDEX_PATH)

      FileUtils.mkdir_p(File.dirname(index_path))
      File.open(index_path, 'w') { |f| f.write(index.to_s) }

      ui_path = Utils.make_path(@site[:source_dir], LUNR_UI_PATH)
      File.open(ui_path, 'w') { |f| f.write(index.default_ui) } if generate_ui
    end

    def iiif(args)
      args.each do |name|
        IiifCollection.new(name, @site).process
      end
    end

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
  end
end
