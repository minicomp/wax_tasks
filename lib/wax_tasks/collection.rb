include FileUtils
require 'csv'
require 'json'

# initializes a wax collection for use with pagemaster,lunr,and iiif tasks
class Collection
  def initialize(config, collection_name)
    @name   = collection_name
    @config = config

    cdir = @config['collections_dir'].nil? ? '' : @config.fetch('collections_dir').to_s + '/'
    collection = valid_collection_config

    @src    = '_data/' + collection.fetch('source')
    @layout = File.basename(collection.fetch('layout'), '.*')
    @dir    = cdir + '_' + @name
  end

  def valid_collection_config
    c = @config['collections'][@name]
    abort "Cannot find the collection #{@name} in _config.yml. Exiting.".magenta if c.nil?
    abort "Cannot find 'source' for the collection '#{@name}' in _config.yml. Exiting.".magenta if c['source'].nil?
    abort "Cannot find 'layout' for the collection '#{@name}' in _config.yml. Exiting.".magenta if c['layout'].nil?
    abort "Cannot find the file '#{'_data/' + c['source']}'. Exiting.".magenta unless File.file?('_data/' + c['source'])
    c
  end

  def ingest(src)
    if File.extname(src) == '.csv'
      data = CSV.read(src, :headers => true, :encoding => 'utf-8').map(&:to_hash)
    elsif File.extname(src) == '.json'
      data = JSON.parse(File.read(@src).encode("UTF-8"))
    else
      puts "File type for #{@src} must be .csv or .json. Please fix and rerun."
      exit 1
    end
    detect_duplicates(data)
    puts "Processing #{src}...."
    data
  rescue StandardError
    puts "Cannot load #{src}. check for typos and rebuild.".magenta
  end

  def generate_pages(data)
    perma_ext = @config['permalink'] == 'pretty' ? '/' : '.html'
    completed = 0
    skipped = 0
    data.each do |item|
      pagename = slug(item.fetch('pid'))
      pagepath = @dir + '/' + pagename + '.md'
      permalink = '/' + @name + '/' + pagename + perma_ext
      if File.exist?(pagepath)
        puts "#{pagename}.md already exits. Skipping."
        skipped += 1
      else
        File.open(pagepath, 'w') { |file| file.write(item.to_yaml.to_s + "permalink: #{permalink}\nlayout: #{@layout}\n---") }
        completed += 1
      end
    end
    puts "\n#{completed} pages were generated to #{@dir} directory.".cyan
    puts "\n#{skipped} pre-existing items were skipped.".cyan
  rescue StandardError
    abort "#{completed} pages were generated before failure, most likely a record is missing a valid 'pid' value.".magenta
  end

  def detect_duplicates(data)
    pids = []
    data.each { |d| pids << d['pid'] }
    duplicates = pids.detect { |p| pids.count(p) > 1 } || []
    raise "\nYour collection has the following duplicate ids. please fix and rerun.\n#{duplicates}".magenta unless duplicates.empty?
  end

  def pagemaster
    mkdir_p(@dir)
    data = ingest(@src)
    generate_pages(data)
  end
end
