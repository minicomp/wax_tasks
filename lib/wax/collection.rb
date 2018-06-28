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
    Error.missing_key('source', @name) if source.nil?
    data = hash_array(src_path("_data/#{source}"))
    puts "Processing #{source}..."
    assert_pids(source, data)
  rescue StandardError => e
    Error.bad_source(source, @name) + "\n#{e}"
  end

  def hash_array(src)
    opts = { headers: true, encoding: 'utf-8' }
    ext  = File.extname(src)
    case ext
    when '.csv' then data = CSV.read(src, opts).map(&:to_hash)
    when '.json' then data = JSON.parse(File.read(src))
    when '.yml' then data = YAML.load_file(src)
    else Error.invalid_type(ext, @name)
    end
    data
  end

  def assert_pids(source, data)
    pids = data.map { |d| d.fetch('pid', nil) }
    Error.missing_pids(source, pids) unless pids.all?
    duplicates = pids.select { |p| pids.count(p) > 1 }.uniq! || []
    Error.duplicate_pids(duplicates, @name) unless duplicates.empty?
    data
  end

  def assert_required(vars)
    vars.each do |v|
      Error.invalid_collection(@name) if instance_variable_get(v).nil?
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
