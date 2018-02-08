include FileUtils

# initializes a wax collection for use with pagemaster,lunr,and iiif tasks
class Collection
  attr_reader :name, :config, :src, :layout, :dir, :data

  def initialize(collection_name, collection_config, collections_dir)
    @name   = collection_name
    @config = collection_config
    @cdir   = collections_dir
    @src    = '_data/' + @config['source']
    @layout = File.basename(@config['layout'], '.*')
    @dir    = @cdir + '_' + @name
    @data   = []
    @lunr   = {}
  end

  def pagemaster
    mkdir_p(@dir)
    ingest
    detect_duplicates
    generate_pages
  end

  def ingest
    if File.extname(@src) == '.csv'
      @data = CSV.read(@src, :headers => true, :encoding => 'utf-8').map(&:to_hash)
    elsif File.extname(@src) == '.json'
      @data = JSON.parse(File.read(@src).encode("UTF-8"))
    else
      puts "File type for #{@src} must be .csv or .json. Please fix and rerun."
      exit 1
    end
    puts "Processing #{src}...."
  rescue StandardError
    puts "Cannot load #{src}. check for typos and rebuild.".magenta
    exit 1
  end

  def generate_pages
    perma_ext = $config['permalink'] == 'pretty' ? '/' : '.html'
    completed = 0
    skipped = 0
    data.each do |item|
      pagename = slug(item['pid'])
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

  def detect_duplicates
    pids = []
    @data.each { |d| pids << d['pid'] }
    duplicates = pids.detect { |p| pids.count(p) > 1 } || []
    raise "\nYour collection has the following duplicate ids. please fix and rerun.\n#{duplicates}".magenta unless duplicates.empty?
  end
end
