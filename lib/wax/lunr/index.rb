# document
class Index
  attr_accessor :collections, :fields, :site_config

  def initialize(opts = {})
    @site_config  = opts.fetch(:site_config, WaxTasks::SITE_CONFIG)
    @collections  = collections_to_index
    @fields       = total_fields
    @path         = construct_path('js/lunr-index.json')

    write_index
  end

  def collections_to_index
    to_index = @site_config[:collections].find_all { |c| c[1].key?('lunr_index') }
    to_index.map! { |c| c[0] }
    Error.no_collections_to_index if to_index.nil?
    lunr_collections = []
    to_index.each { |c| lunr_collections << LunrCollection.new(c) }
    lunr_collections
  end

  def total_fields
    total_fields = ['pid']
    @collections.each { |c| total_fields.concat(c.fields) unless c.fields.nil? }
    total_fields.uniq
  end

  def write_index
    docs = []
    @collections.each { |c| docs.concat(c.data) }
    docs = add_lunr_ids(docs)
    FileUtils.mkdir_p(File.dirname(@path))
    index = "---\nlayout: none\n---\n#{JSON.pretty_generate(docs)}"
    File.open(@path, 'w') { |f| f.write(index) }
    Message.writing_index(@path)
  end

  def add_lunr_ids(documents)
    count = 0
    docs_with_ids = []
    documents.each do |d|
      d['lunr_id'] = count
      docs_with_ids << d
      count += 1
    end
    docs_with_ids
  end

  def construct_path(path)
    "#{@site_config[:source_dir]}/#{path}" if @site_config[:source_dir]
  end
end
