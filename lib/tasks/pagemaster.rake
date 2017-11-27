require 'yaml'
require 'csv'

namespace :wax do
  task :pagemaster => :config do
    @collections = @config['collections']
    @argv.each do |a|
      collection = @collections[a]
      unless collection.nil?
        @src = collection['source'].to_s
        @key = collection['key'].to_s
        @dir = collection['directory'].to_s
        @layout = collection['layout'].to_s

        if @src.empty? || @key.empty? || @dir.empty? || @layout.empty?
          raise "wax:pagemaster :: your collection is missing one or more of the required parameters (source, key, directory, layout) in config. please fix and rerun."
    		else
          @ext = File.extname(@src).strip.downcase[1..-1]
          unless @ext == 'yaml' || @ext == 'csv'
            raise "wax:pagemaster :: source file must be .csv or .yaml. please fix and rerun."
          else

    				@targetdir = "_" + @dir.downcase.gsub(/[^\0-9a-z]/, '').to_s
    				FileUtils::mkdir_p @targetdir
    				puts "wax:pagemaster :: made directory " + @targetdir + " in root."

      			def ingest(src) # takes + opens src file
      				begin
      					puts ">> wax:pagemaster :: loaded " + src + "."
                if @ext == 'yaml'
                  return YAML.load_file('_data/' + src)
                else
                  return CSV.read('_data/' + src, :headers => true).map(&:to_hash)
                end
      				rescue
      					raise "wax:pagemaster :: cannot load " + src + ". check for typos and rebuild."
      				end
      			end

      			def uniqify(hashes, key) # takes opened src file as hash array
      				occurences = {} # hash list of slug names and # of occurences
      				hashes.each do |item|
      					if item[key].nil?
      						raise "wax:pagemaster :: source file has at least one missing value for key='" + key + "'. cannot generate."
      					end
      					new_name = item[key].downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '').gsub(/-+/, '-') # gsub for slug
      					if occurences.has_key? new_name
      						occurences[new_name]+=1
      						safe_slug = new_name + "-" + occurences[new_name].to_s
      					else
      						occurences.store(new_name, 1)
      						safe_slug = new_name
      					end
      					item.store("slug", safe_slug)
      				end
      				return hashes # return changed yml array with unique, slugified names added
      			end

      			# ingest data source, sort it and generate unique titles
      			data = uniqify(ingest(@src), @key)
      			untitled, nonunique, valid = 0, 0, 0

      			# make pages
      			data.each do |item|
      				pagename = item["slug"]
      				pagepath = @targetdir + "/" + pagename + ".md"
      				layout_str = "layout: " + @layout
      				if pagename.empty?
      					puts ">> wax:pagemaster :: title for item is unspecified. cannot generate page."
      					untitled+=1
      				elsif !File.exist?(pagepath)
      					File.open(pagepath, 'w') { |file| file.write( item.to_yaml.to_s + layout_str + "\n---" ) }
      					valid+=1
      				else
      					puts ">> wax:pagemaster :: " + pagename + ".md already exits."
      					nonunique+=1
      				end
      			end

      			# log outcomes
      			puts ">> wax:pagemaster :: " + valid.to_s + " pages were generated from " + @src + " to " + @targetdir + " directory."
      			puts ">> wax:pagemaster :: " + nonunique.to_s + " items were skipped because of non-unique names."
      			puts ">> wax:pagemaster :: " + untitled.to_s + " items were skipped because of missing titles."
          end
        end
      end
    end
  end
end
