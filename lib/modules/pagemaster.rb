require 'colorized_string'
require 'csv'
require 'fileutils'
require 'json'
require 'yaml'

# module for generating markdown collection pages from csv/json/yaml records
module Pagemaster
  def self.generate(collection, site_config)
    records = WaxTasks.ingest(collection[:source])
    dir = target_dir(collection[:name], site_config)
    permalink_style = WaxTasks.permalink_style(site_config)

    completed = 0
    skipped = 0

    records.each_with_index do |item, index|
      pagename = WaxTasks.slug(item.fetch('pid').to_s)
      pagepath = "#{dir}/#{pagename}.md"
      if File.exist?(pagepath)
        puts "#{pagename}.md already exits. Skipping."
        skipped += 1
      else
        item['permalink'] = "/#{collection[:name]}/#{pagename}#{permalink_style}"
        item['layout'] = collection[:layout]
        item['order'] = padded_int(index, records.length) if collection[:keep_order]
        File.open(pagepath, 'w') { |f| f.write(item.to_yaml.to_s + '---') }
        completed += 1
      end
    end

    puts "\n#{completed} pages were generated to #{dir} directory.".cyan
    puts "\n#{skipped} pre-existing items were skipped.".cyan
  rescue StandardError => e
    abort "Failure after #{completed} pages, likely from missing pid.".magenta + "\n#{e}"
  end

  def self.padded_int(index, max_idx)
    index.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
  end

  def self.target_dir(collection_name, site_config)
    collections_dir = site_config['collections_dir'].to_s
    dir = collections_dir.empty? ? '_' : collections_dir + '/_'
    dir += collection_name
    FileUtils.mkdir_p(dir)
    dir
  end
end
