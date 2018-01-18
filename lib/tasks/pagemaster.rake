require 'yaml'
require 'csv'
require 'colorized_string'

namespace :wax do
  desc 'generate collection md pages from yaml or csv data source'
  task :pagemaster => :config do
    collections = $config['collections']
    if $argv.empty?
      puts "You must specify one or more collections after 'bundle exec rake wax:pagemaster' to generate.".magenta
      exit 1
    else
      $argv.each do |a|
        collection = collections[a]
        if collection.nil?
          puts "The collection '#{a}' does not exist. Check for typos in terminal and _config.yml.".magenta
          exit 1
        else
          meta = {}
          meta['src'] = '_data/' + File.basename(collection['source'], '.*') + '.csv'
          meta['layout'] = File.basename(collection['layout'], '.*')
          meta['dir'] = collection['directory']
          if [meta['src'], meta['dir'], meta['layout']].all?
            FileUtils.mkdir_p meta['dir']
            data = ingest(meta['src'])
            info = generate_pages(meta, data)
            puts "\n#{info[:completed]} pages were generated to #{meta['dir']} directory.".cyan
            puts "\n#{info[:skipped]} pre-existing items were skipped.".cyan
          else
            puts "\nYour collection '#{a}' is missing one or more of the required parameters (source, directory, layout) in config. please fix and rerun.".magenta
            exit 1
          end
        end
      end
    end
  end
end

def ingest(src)
  data = CSV.read(src, :headers => true, :encoding => 'utf-8')
  duplicates = data['pid'].detect { |i| data.count(i) > 1 }.to_s
  unless duplicates.empty?
    puts "\nYour collection has the following duplicate ids. please fix and rerun.\n#{duplicates} \n".magenta
    exit 1
  end
  puts "Processing #{src}...."
  return data.map(&:to_hash)
rescue StandardError
  puts "Cannot load #{src}. check for typos and rebuild.".magenta
  exit 1
end

def generate_pages(meta, data)
  perma_ext = '.html'
  perma_ext = '/' if $config['permalink'] == 'pretty'
  info = { :completed => 0, :skipped => 0 }
  data.each do |item|
    pagename = item['pid']
    pagepath = meta['dir'] + '/' + pagename + '.md'
    if !File.exist?(pagepath)
      File.open(pagepath, 'w') { |file| file.write(item.to_yaml.to_s + 'permalink: /' + meta['dir'] + '/' + pagename + perma_ext + "\n" + 'layout: ' + meta['layout'] + "\n---") }
      info[:completed] += 1
    else
      puts "#{pagename}.md already exits. Skipping."
      info[:skipped] += 1
    end
  end
  return info
rescue standardError
  puts "#{info[:completed]} pages were generated before failure, most likely a record is missing a valid 'pid' value.".magenta
  exit 1
end
