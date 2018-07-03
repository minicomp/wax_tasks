# document
class Collection
  def initialize(name, opts = {})
    @name             = name
    @site_config      = opts.fetch(:site_config, WaxTasks::SITE_CONFIG)
    @config           = @site_config[:collections].fetch(@name, nil)
    @page_dir         = construct_page_dir

    assert_required(instance_variables)
  end

  def ingest(source)
    source = src_path("_data/#{source}")
    raise Error::MissingSource, "Cannot find #{source}" unless File.exist? source
    ext  = File.extname(source)
    case ext
    when '.csv'
      data = CSV.read(source, { headers: true, encoding: 'utf-8' }).map(&:to_hash)
    when '.json'
      data = JSON.parse(File.read(source))
    when '.yml'
      data = YAML.load_file(source)
    else
      raise Error::InvalidSource, "Cannot load #{ext} files. Culprit: #{source}"
    end
    assert_pids(data)
  end

  def assert_pids(data)
    pids    = data.map { |d| d.fetch('pid', nil) }
    missing = data.length - pids.compact.length
    raise Error::MissingPid, "#{@name} is missing #{missing} pids." unless pids.all?
    not_unique = pids.select { |p| pids.count(p) > 1 }.uniq! || []
    puts "not unique #{not_unique}"
    raise Error::NonUniquePid, "#{@name} has the following nonunique pids:\n#{not_unique}" unless not_unique.empty?
    data
  end

  def assert_required(vars)
    vars.each do |v|
      raise Error::InvalidCollection, "Configuration for the collection '#{@name}' is invalid." if instance_variable_get(v).nil?
    end
  end

  def construct_page_dir
    dir = "_#{@name}"
    dir = "#{@site_config[:collections_dir]}/#{dir}" if @site_config[:collections_dir]
    dir = "#{@site_config[:source_dir]}/#{dir}" if @site_config[:source_dir]
    dir
  end

  def src_path(path)
    path = "#{@site_config[:source_dir]}/#{path}" if @site_config[:source_dir]
    path
  end
end
