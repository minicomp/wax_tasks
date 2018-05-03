require 'colorized_string'
require 'csv'
require 'json'
require 'yaml'

# module for generating markdown collection pages from csv/json/yaml records
module Pagemaster
  def self.valid_config(name, site_config)
    unless site_config['collections'].key?(name)
      abort "Cannot find #{name} in _config.yml. Exiting.".magenta
    end
    collection_config = site_config['collections'][name]
    unless collection_config['source']
      abort "Cannot find source for '#{name}'. Exiting.".magenta
    end
    unless collection_config['layout']
      abort "Cannot find layout for '#{name}'. Exiting.".magenta
    end
    unless File.file?('_data/' + collection_config['source'])
      abort "Cannot find the file _data/#{collection_config['source']}.".magenta
    end
    collection_config
  end

  def self.ingest(src)
    src = "_data/#{src}"
    opts = { headers: true, encoding: 'utf-8' }
    case File.extname(src)
    when '.csv' then data = CSV.read(src, opts).map(&:to_hash)
    when '.json' then data = JSON.parse(File.read(src))
    when '.yml' then data = YAML.load_file(src)
    else abort "Source '#{src}' must be .csv, .json, or .yml."
    end
    puts "Processing #{src}...."
    pids = data.map { |d| d['pid'] }
    duplicates = pids.detect { |p| pids.count(p) > 1 } || []
    abort "Fix duplicate pids: \n#{duplicates}".magenta unless duplicates.empty?
    data
  rescue StandardError
    puts "Cannot load #{src}. check for typos and rebuild.".magenta
  end

  def self.generate_pages(data, name, layout, cdir, order, perma)
    if cdir.empty?
      dir = '_' + name
    else
      FileUtils.mkdir_p(cdir)
      dir = cdir + '/_' + name
    end
    FileUtils.mkdir_p(dir)
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
  rescue StandardError
    abort "Failure after #{completed} pages, likely from missing pid.".magenta
  end

  def self.padded_int(index, max_idx)
    index.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
  end
end
