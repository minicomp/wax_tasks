require 'yaml'
require 'csv'

namespace :wax do
  task :pagemaster => :config do
    def slug(s)
      return s.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '').to_s
    end

    def ingest(src) # takes + opens src file
      ext = File.extname(src).strip[1..-1]
      unless ext == 'yaml' || ext == 'csv'
        raise "wax:pagemaster :: source file must be .csv or .yaml. please fix and rerun."
      else
        begin
          if ext == 'yaml'
            data = YAML.load_file('_data/' + src)
          else
            data = CSV.read('_data/' + src, :headers => true)
            dups = data['pid'].detect{ |i| data.count(i) > 1 }.to_s
            unless dups.empty?
              raise "wax:pagemaster :: your collection has the following duplicate ids. please fix and rerun.\n" + dups +"\n"
            end
            return data.map(&:to_hash)
          end
        rescue
          raise "wax:pagemaster :: cannot load " + src + ". check for typos and rebuild."
        end
      end
    end

    @collections = @config['collections']
    @argv.each do |a|
      collection = @collections[a]
      unless collection.nil?
        @src = collection['source'].to_s
        @dir = collection['directory'].to_s
        @targetdir = "_" + @dir
        @layout = collection['layout'].to_s

        if @src.empty? || @dir.empty? || @layout.empty?
          raise "wax:pagemaster :: your collection is missing one or more of the required parameters (source, key, directory, layout) in config. please fix and rerun."
    		else
    			FileUtils::mkdir_p @targetdir

    			# ingest data source, sort it and generate unique titles
    			data = ingest(@src)
    			untitled, nonunique, valid = 0, 0, 0

    			# make pages
    			data.each do |item|
    				@pagename = item['pid']
    				@pagepath = @targetdir + "/" + @pagename + ".md"
            @perma_str = "permalink: /" + @dir + "/" + @pagename
    				@layout_str = "layout: " + @layout

    				if @pagename.empty?
    					puts ">> wax:pagemaster :: title for item is unspecified. cannot generate page."
    					untitled+=1
    				elsif !File.exist?(@pagepath)
    					File.open(@pagepath, 'w') { |file| file.write( item.to_yaml.to_s + @perma_str + "\n" + @layout_str + "\n---" ) }
    					valid+=1
    				else
    					puts ">> wax:pagemaster :: " + @pagename + ".md already exits."
    					nonunique+=1
    				end

    			end

    			# log outcomes
    			puts valid.to_s + " pages were generated from " + @src + " to " + @targetdir + " directory."
    			puts nonunique.to_s + " items were skipped because of non-unique names."
    			puts untitled.to_s + " items were skipped because of missing titles."
        end
      end
    end
  end
end
