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
      raise Error::WaxTasksError, "No labels file was found for collection '#{@name}'" if label_file.nil?
      raise Error::WaxTasksError, "Labels file for collection '#{@name}' must be in YAML format" unless File.extname(label_file) =~ /\.ya?ml/
      label_path = Utils.root_path(@site[:source_dir], '_data', label_file)
      Utils.validate_yaml(label_path).map { |i| i['key'] }
    rescue StandardError => e
      raise Error::WaxTasksError, "Label file #{label_path} could not be loaded. Make sure it is a valid YAML file.\n#{e}"
    end

   
  end
end
