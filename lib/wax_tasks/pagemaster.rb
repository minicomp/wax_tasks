require 'json'
require 'yaml'
require 'csv'

module Pagemaster
  include FileUtils

  def self.valid_config(name, site_config)
    abort "Cannot find #{name} in _config.yml. Exiting.".magenta unless site_config['collections'].key?(name)
    collection_config = site_config['collections'][name]
    abort "Cannot find source for '#{name}'. Exiting.".magenta unless collection_config['source']
    abort "Cannot find layout for '#{name}'. Exiting.".magenta unless collection_config['layout']
    abort "Cannot find the file _data/#{collection_config['source']}.".magenta unless File.file?('_data/' + collection_config['source'])
    collection_config
  end

  def self.ingest(src)
    src = "_data/#{src}"
    case File.extname(src)
    when '.csv' then data = CSV.read(src, :headers => true, :encoding => 'utf-8').map(&:to_hash)
    when '.json' then data = JSON.parse(File.read(src))
    when '.yml' then data = YAML.load_file(src)
    else abort "File type for #{src} must be .csv, .json, or .yml. Please fix and rerun."
    end
    puts "Processing #{src}...."
    detect_duplicates(data)
    data
  rescue StandardError
    puts "Cannot load #{src}. check for typos and rebuild.".magenta
  end

  def self.generate_pages(data, name, layout, cdir, order, perma)
    dir = cdir + '_' + name
    mkdir_p(dir)
    completed = 0
    skipped = 0
    data.each_with_index do |item, index|
      pagename = WaxTasks.slug(item.fetch('pid'))
      pagepath = dir + '/' + pagename + '.md'
      if File.exist?(pagepath)
        puts "#{pagename}.md already exits. Skipping."
        skipped += 1
      else
        item['permalink'] = '/' + name + '/' + pagename + perma
        item['layout'] = layout
        item['order'] = padded_int(index, data.length) if order
        File.open(pagepath, 'w') { |f| f.write(item.to_yaml.to_s + '---') }
        completed += 1
      end
    end
    puts "\n#{completed} pages were generated to #{dir} directory.".cyan
    puts "\n#{skipped} pre-existing items were skipped.".cyan
  # rescue StandardError
    # abort "#{completed} pages were generated before failure, most likely a record is missing a valid 'pid' value.".magenta
  end

  def self.detect_duplicates(data)
    pids = []
    data.each { |d| pids << d['pid'] }
    duplicates = pids.detect { |p| pids.count(p) > 1 } || []
    abort "\nYour collection has the following duplicate pids: \n#{duplicates}".magenta unless duplicates.empty?
  end

  def self.padded_int(index, max_idx)
    index.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
  end
end
