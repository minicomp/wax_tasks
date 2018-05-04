require 'colorized_string'
require 'csv'
require 'json'
require 'yaml'

require 'wax_tasks'

# module for generating markdown collection pages from csv/json/yaml records
module Pagemaster
  def self.ingest(source)
    src = "_data/#{source}"
    abort "Cannot find #{src}" if !File.exist?(src)
    src_ext = File.extname(source)
    opts = { headers: true, encoding: 'utf-8' }
    case File.extname(src)
    when '.csv' then data = CSV.read(src, opts).map(&:to_hash)
    when '.json' then data = JSON.parse(File.read(src))
    when '.yml' then data = YAML.load_file(src)
    else abort "Source #{src} must be .csv, .json, or .yml."
    end
    puts "Processing #{src}...."
    pids = data.map { |d| d['pid'] }
    duplicates = pids.detect { |p| pids.count(p) > 1 } || []
    abort "Fix duplicate pids: \n#{duplicates}".magenta unless duplicates.empty?
    data
  rescue StandardError
    abort "Cannot load #{src}. check for typos and rebuild.".magenta
  end

  def self.generate(collection, records)
    site_config = WaxTasks.site_config
    collections_dir = site_config['collections_dir'].to_s
    permalink_style = WaxTasks.permalink_style(site_config)
    if collections_dir.empty?
      dir = '_' + collection.name
    else
      FileUtils.mkdir_p(collections_dir)
      dir = collections_dir + '/_' + collection.name
    end
    FileUtils.mkdir_p(dir)
    completed = 0
    skipped = 0
    records.each_with_index do |item, index|
      pagename = WaxTasks.slug(item.fetch('pid'))
      pagepath = dir + '/' + pagename + '.md'
      if File.exist?(pagepath)
        puts "#{pagename}.md already exits. Skipping."
        skipped += 1
      else
        item['permalink'] = '/' + collection.name + '/' + pagename + permalink_style
        item['layout'] = collection.layout
        item['order'] = padded_int(index, records.length) if collection.keep_order
        File.open(pagepath, 'w') { |f| f.write(item.to_yaml.to_s + '---') }
        completed += 1
      end
    end
    puts "\n#{completed} pages were generated to #{dir} directory.".cyan
    puts "\n#{skipped} pre-existing items were skipped.".cyan
  rescue StandardError
    abort "Failure after #{completed} pages, likely from missing pid.".magenta
  end

  def self.padded_int(index, max_idx)
    index.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
  end
end
