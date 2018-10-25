module WaxTasks
  # Parent class representing a Jekyll collection
  # that cannot be created directly. Only child classes
  # (IiifCollection, LunrCollection, PagemasterCollection)
  # can be initialized.
  class Collection
    attr_accessor :name, :site
    private_class_method :new

    # This method ensures child classes can be instantiated though
    # Collection.new cannot be.
    def self.inherited(*)
      public_class_method :new
    end

    # Creates a new collection with name @name given site configuration @site
    #
    # @param  name      [String]  name of the collection in site:collections
    # @param  site      [Hash]    site config
    def initialize(name, site)
      @name     = name
      @site     = site
    end

    # Finds the collection config within the site config
    #
    # @return [Hash] the config for the collection
    def config
      @site[:collections].fetch(@name)
    rescue StandardError => e
      raise Error::InvalidCollection, "Cannot load collection config for #{@name}.\n#{e}"
    end

    # Returns the target directory for generated collection pages
    #
    # @return [String] path
    def page_dir
      Utils.make_path(@site[:source_dir], @site[:collections_dir], "_#{@name}")
    end

    # Constructs the path to the data source file
    #
    # @return [String] the path to the data source file
    def source_path
      raise WaxTasks::Error::MissingSource, "Missing collection source in _config.yml for #{@name}" unless self.config.key? 'source'
      WaxTasks::Utils.make_path(@site[:source_dir], '_data', self.config['source'])
    end


    # Ingests the collection source data as an Array of Hashes
    #
    # @param source [String] the path to the CSV, JSON, or YAML source file
    # @return [Array] the collection data
    def ingest_file(source)
      raise Error::MissingSource, "Cannot find #{source}" unless File.exist? source

      data = case File.extname(source)
             when '.csv'
               WaxTasks::Utils.validate_csv(source)
             when '.json'
               WaxTasks::Utils.validate_json(source)
             when /\.ya?ml/
               WaxTasks::Utils.validate_yaml(source)
             else
               raise Error::InvalidSource, "Can't load #{File.extname(source)} files. Culprit: #{source}"
             end

      WaxTasks::Utils.assert_pids(data)
      WaxTasks::Utils.assert_unique(data)
    end
  end
end
