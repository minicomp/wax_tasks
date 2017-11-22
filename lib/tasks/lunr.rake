require 'json'
require 'yaml'

namespace :wax do
  task :lunr => :config do
    @config['lunr']['meta'].each do |group|
      @dir = group['dir']
      @fields = group['fields']
      Dir.glob(@dir+"/*.md").each do |file|
        if @config['lunr']['content']
          @content = File.read(file)
          puts "content: " + @content
        end
        @meta = YAML.load_file(file)
        @fields.each do |field|
          if @meta[field].kind_of?(Array)
            puts field + " is an array"
            puts field + ": " + @meta[field].join(", ")
          else
            puts field + " is a string"
            puts field + ": " + @meta[field]
          end
        end
      end
    end
  end
end
