# document
class Index
  attr_accessor :collections, :fields, :site_config

  def initialize(opts = {})
    @site_config  = opts.fetch(:site_config, WaxTasks::SITE_CONFIG)
    @collections  = lunr_collections
    @fields       = total_fields
    @path         = construct_path('js/lunr-index.json')

    write_index
  end

  def lunr_collections
    site_collections = @site_config[:collections]
    to_index = site_collections.find_all { |c| c[1].key?('lunr_index') }
    to_index.map! { |c| c[0] }
    # raise Error::no_collections_to_index if to_index.nil?
    to_index.map { |c| LunrCollection.new(c) }
  end

  def total_fields
    total_fields = ['pid']
    @collections.each { |c| total_fields.concat(c.fields) unless c.fields.nil? }
    total_fields.uniq
  end

  def write_index
    docs = @collections.map(&:data)
    docs.map_with_index! { |d, id| d['lunr_id'] = id }
    index = "---\nlayout: none\n---\n#{JSON.pretty_generate(docs)}"
    FileUtils.mkdir_p(File.dirname(@path))
    File.open(@path, 'w') { |f| f.write(index) }
    # Message.writing_index(@path)
  end

  def construct_path(path)
    "#{@site_config[:source_dir]}/#{path}" if @site_config[:source_dir]
  end
end
