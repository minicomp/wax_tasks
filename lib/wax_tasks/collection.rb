# document
class Collection
  def initialize(name, opts = {})
    @name             = name
    @site_config      = opts.fetch(:site_config, WaxTasks::SITE_CONFIG)
    @config           = @site_config[:collections].fetch(@name, nil)
    @page_dir         = construct_page_dir

    assert_required_instance_vars
  end

  def ingest(source)
    source = src_path("_data/#{source}")
    raise Error::MissingSource, "Cannot find #{source}" unless File.exist? source
    case File.extname(source)
    when '.csv' then data = CSV.read(source, headers: true).map(&:to_hash)
    when '.json' then data = JSON.parse(File.read(source))
    when '.yml' then data = YAML.load_file(source)
    else raise Error::InvalidSource, "Cannot load #{File.extname(source)} files. Culprit: #{source}"
    end

    WaxTasks::Utils.assert_pids(data)
    WaxTasks::Utils.assert_unique(data)
  end

  def assert_required_instance_vars
    no_name         = @name.to_s.empty?
    no_site_config  = @site_config.to_s.empty?
    no_config       = @config.to_s.empty?
    no_page_dir     = @page_dir.to_s.empty?

    raise Error::InvalidCollection, 'Missing collection @name variable' if no_name
    raise Error::InvalidCollection, 'Missing collection @site_config variable' if no_site_config
    raise Error::InvalidCollection, 'Missing collection @config' if no_config
    raise Error::InvalidCollection, 'Cannot construct the page directory @page_dir' if no_page_dir
  end

  def construct_page_dir
    dir = [@site_config[:source_dir], @site_config[:collections_dir], @name]
    dir.compact.join('/')
  end

  def src_path(path)
    [@site_config[:source_dir], path].compact.join('/')
  end
end
