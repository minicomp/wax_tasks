# NOTE: DATA REQUIRES A UNIQUE FIELD 'pid'

require 'yaml'
require 'csv'

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
          puts ("The collection '" + a + "' does not exist. Check for typos in terminal and _config.yml.").magenta
          exit 1
        else

          meta = Hash.new
          meta['src']     = '_data/' + File.basename( collection['source'], ".*" ) + ".csv"
          meta['layout']  = File.basename( collection['layout'], ".*" ) + ".html"
          meta['dir']     = collection['directory']

          $skipped, $completed = 0,0

          unless [ meta['src'], meta['dir'], meta['layout'] ].all?
            puts ("Your collection " + a +" is missing one or more of the required parameters (source, directory, layout) in config. please fix and rerun.").magenta
            exit 1
      		else
      			FileUtils::mkdir_p meta['dir']
      			data = ingest(meta['src'])
            generate_pages(meta, data)
      			puts ("\n" + $completed.to_s + " pages were generated to " + meta['dir'] + " directory.").green
      			puts ($skipped.to_s + " pre-existing items were skipped.").green
          end
        end
      end
    end
  end
end

def ingest(src)
  begin
    data = CSV.read(src, :headers => true, :encoding => 'utf-8')
    duplicates = data['pid'].detect{ |i| data.count(i) > 1 }.to_s
    unless duplicates.empty?
      puts ("Your collection has the following duplicate ids. please fix and rerun.\n").magenta + duplicates +"\n"
      exit 1
    end
    puts ("\nProcessing " + src + "....\n").cyan
    return data.map(&:to_hash)
  rescue
    puts ("Cannot load " + src + ". check for typos and rebuild.").magenta
    exit 1
  end
end

def generate_pages(meta, data)
  data.each do |item|
    begin
      pagename = item['pid']
      pagepath = meta['dir'] + "/" + pagename + ".md"
      if !File.exist?(pagepath)
        File.open(pagepath, 'w') { |file| file.write( item.to_yaml.to_s + "permalink: /" + meta['dir'] + "/" + pagename + "\n" + "layout: " + meta['layout'] + "\n---" ) }
        $completed+=1
      else
        # puts pagename + ".md already exits. Skipping."
        $skipped+=1
      end
    rescue
      puts ($completed.to_s + " pages were generated before failure, most likely a record is missing a valid 'pid' value.").magenta
      exit 1
    end
  end
end
