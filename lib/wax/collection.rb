# document
class Collection
  def initialize(name, opts = {})
    @name     = name
    @s_conf   = opts.fetch(:site_config, WaxTasks.site_config)
    @c_conf   = @s_conf.fetch(:collections).fetch(@name, nil)
    @page_dir = "_#{@name}"
    if @s_conf.fetch(:c_dir, false)
      @page_dir = "#{@s_conf[:c_dir]}/#{@page_dir}"
    end
    assert_required(instance_variables)
  end

  def ingest(source)
    Error.missing_key('source', @name) if source.nil?
    src_path = "_data/#{source}"
    data = hash_array(src_path)
    Message.processing_source(source)
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
end
