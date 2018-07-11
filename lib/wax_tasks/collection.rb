# document
class Collection
  attr_reader :name, :site_config, :config, :page_dir

  def initialize(name, opts = {})
    @name         = name
    @site_config  = opts.fetch(:site_config, WaxTasks::SITE_CONFIG)
    @config       = collection_config
    @page_dir     = construct_page_dir
  end

  def collection_config
    collections = @site_config.fetch(:collections, nil)
    raise WaxTasks::Error::InvalidCollection, 'No valid collections in _config.yml' if collections.nil?
    config = collections.fetch(@name, nil)
    raise WaxTasks::Error::InvalidCollection, "Cannot find collection #{@name} in _config.yml" if config.nil?
    config
  end

  def ingest(source)
    source = src_path("_data/#{source}")
    raise WaxTasks::Error::MissingSource, "Cannot find #{source}" unless File.exist? source

    case File.extname(source)
    when '.csv'     then data = WaxTasks::Utils.validate_csv(source)
    when '.json'    then data = WaxTasks::Utils.validate_json(source)
    when /\.ya?ml/  then data = WaxTasks::Utils.validate_yaml(source)
    else raise WaxTasks::Error::InvalidSource, "Cannot load #{File.extname(source)} files. Culprit: #{source}"
    end

    WaxTasks::Utils.assert_pids(data)
    WaxTasks::Utils.assert_unique(data)
  end

  def assert_required_instance_vars
    no_name         = @name.to_s.empty?
    no_site_config  = @site_config.to_s.empty?
    no_config       = @config.to_s.empty?
    no_page_dir     = @page_dir.to_s.empty?

    raise WaxTasks::Error::InvalidCollection, 'Missing collection @name variable' if no_name
    raise WaxTasks::Error::InvalidCollection, 'Missing collection @site_config variable' if no_site_config
    raise WaxTasks::Error::InvalidCollection, 'Missing collection @config' if no_config
    raise WaxTasks::Error::InvalidCollection, 'Cannot construct the page directory @page_dir' if no_page_dir
  end

  def src_path(path)
    [@site_config[:source_dir], path].compact.join('/')
  end

  def construct_page_dir
    dir = [@site_config[:source_dir], @site_config[:collections_dir], @name]
    dir.compact.join('/')
  end
end
