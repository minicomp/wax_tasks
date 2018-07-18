module WaxTasks
  # document
  class LunrCollection < Collection
    attr_accessor :fields, :data

    def initialize(name, site)
      super(name, site)

      @index_config = @config[:lunr_index].symbolize_keys
      @content      = @index_config.fetch(:content, false)
      @fields       = @index_config.fetch(:fields, [])
      @data         = ingest_pages

      raise Error::MissingFields, "There are no fields for #{@name}.".magenta if @fields.empty?
    end

    def ingest_pages
      data  = []
      pages = Dir.glob("#{@page_dir}/*.md")
      puts "There are no pages in #{@page_dir} to index.".cyan if pages.empty?
      pages.each do |p|
        begin
          data << load_page(p)
        rescue StandardError => e
          raise Error::LunrPageLoad, "Cannot load page #{p}\n#{e}"
        end
      end
      data
    end

    def load_page(page)
      yaml = YAML.load_file(page)
      hash = {
        'link' => "{{'#{yaml.fetch('permalink')}' | relative_url }}",
        'collection' => @name
      }
      hash['content'] = File.read(page).html_strip.remove_diacritics if @content
      fields = @fields.push('pid').uniq
      fields.each { |f| hash[f] = yaml[f].normalize }
      hash
    end
  end
end
