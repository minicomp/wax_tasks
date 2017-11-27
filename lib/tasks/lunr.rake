require 'json'
require 'yaml'

namespace :wax do
  task :lunr => :config do

    @meta = @config['lunr']['meta']
    @name = @config['lunr']['name'].to_s

    total_fields = []
    index_string = "var idx = lunr(function () { this.ref('lunr_id') "
    count = 0

    if @meta.to_s.empty? || @name.empty?
      raise "wax:lunr :: lunr index parameters are not cofigured. continuing."
    else
      @meta.each { |group| total_fields += group['fields'] }
      if total_fields.uniq.empty?
        raise "wax:lunr :: fields are not properly configured. aborting."
      else
        total_fields.uniq.each { |f| index_string += "this.field(" + "'" + f + "'" + ") "}

        @meta.each do |group|
          @dir = group['dir']
          @fields = group['fields']

          Dir.glob(@dir+"/*.md").each do |md|
            begin
              @yaml = YAML.load_file(md)
              @hash = Hash.new
              @hash['lunr_id'] = count
              @fields.each { |f| @hash[f] = @yaml[f].to_s }
              if @config['lunr']['content']
                @hash['content'] = File.read(md).gsub(/\A---(.|\n)*?---/, "").to_s
              end
              index_string += "this.add(" + @hash.to_json + ") "
              count += 1
            rescue
              raise "wax:lunr :: cannot load data from markdown pages in " + dir + ". aborting."
            end
          end
        end

        index_string += "})"
        pagepath = "_includes/" + @name + ".html"
        File.open(pagepath, 'w') { |file| file.write( index_string ) }
        puts "wax:lunr :: writing lunr index to " + pagepath
      end
    end
  end
end
