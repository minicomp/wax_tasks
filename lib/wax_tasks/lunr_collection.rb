module WaxTasks
  # A Jekyll collection to be Indexed in a Lunr Index / JSON file
  # for client-side search.
  #
  # @attr index_config  [Hash]    the collection's lunr_index config
  # @attr content       [Boolean] whether/not page content should be indexed
  # @attr fields        [Array]   the fields (i.e., keys) that should be indexed
  # @attr data          [Array]   hash array of data from the ingested md pages
  class LunrCollection < Collection
    attr_accessor :fields, :data, :source

    # Creates a new LunrCollection with name @name given site config @site
    def initialize(name, site)
      super(name, site)

      @config       = self.config
      @fields       = self.process_fields
      @data         = self.ingest_pages

      raise Error::MissingFields, "There are no fields for #{@name}.".magenta if @fields.empty?
    end

    def process_fields
      label_file = @config.dig('metadata', 'labels')
      raise WaxTasks::WaxTasksError, "No labels file was found for collection #{@name}" if label_file.nil?
      label_path = Utils.root_path(@site[:source_dir], '_data', label_file)
      Utils.validate_csv(label_path).map { |i| i['key'] }
    rescue StandardError => e
      raise Error::WaxTasksError, "Label file #{label_path} could not be loaded. Make sure it is a valid CSV.\n#{e}"
    end

    # Finds the page_dir of markdown pages for the collection and ingests
    # them as an array of hashes
    #
    # @return [Array] array of the loaded markdown pages loaded as hashes
    def ingest_pages
      data  = []
      pages = Dir.glob("#{self.page_dir}/*.md")
      puts "There are no pages in #{self.page_dir} to index.".cyan if pages.empty?
      pages.each do |p|
        begin
          data << load_page(p)
        rescue StandardError => e
          raise Error::LunrPageLoad, "Cannot load page #{p}\n#{e}"
        end
      end
      data
    end

    # Reads in a markdown file and converts it to a hash
    # with the values from @fields.
    # Adds the content of the file (below the YAML) if @content == true
    #
    # @param page [String] the path to a markdown page to load
    def load_page(page)
      yaml = YAML.load_file(page)
      hash = {
        'link' => "{{'#{yaml.fetch('permalink')}' | relative_url }}",
        'collection' => @name
      }
      content = WaxTasks::Utils.html_strip(File.read(page))
      hash['content'] = WaxTasks::Utils.remove_diacritics(content)
      fields = @fields.push('pid').uniq
      fields.push('thumbnail') if yaml.key?('thumbnail')
      fields.each { |f| hash[f] = yaml[f].lunr_normalize }
      hash
    end
  end
end
