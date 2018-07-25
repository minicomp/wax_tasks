module WaxTasks
  # Parent class representing a Jekyll collection
  # that cannot be created directly. Only child classes
  # (IiifCollection, LunrCollection, PagemasterCollection)
  # can be initialized.
  #
  # @attr config    [Hash]    the collection config within site config
  # @attr name      [String]  the name of the collection in site:collections
  # @attr page_dir  [String]  the directory path for generated collection pages
  # @attr site      [Hash]    the site config
  class Collection
    attr_reader :name, :page_dir
    private_class_method :new

    # This method ensures child classes can be instantiated though
    # Collection.new cannot be.
    def self.inherited(*)
      public_class_method :new
    end

    # Creates a new collection with name @name given site config @site
    #
    # @param name     [String]  the name of the collection in site:collections
    # @param site     [Hash]    the site config
    def initialize(name, site)
      @name     = name
      @site     = site
      @config   = collection_config
      @page_dir = Utils.make_path(@site[:source_dir],
                                  @site[:collections_dir],
                                  @name)
    end

    # Finds the collection config within the site config
    #
    # @return [Hash] the config for the collection
    def collection_config
      @site[:collections].fetch(@name)
    rescue StandardError => e
      raise Error::InvalidCollection, "Cannot load collection config for #{@name}.\n#{e}"
    end

    # Ingests the collection source data as an Array of Hashes
    #
    # @param source [String] the path to the CSV, JSON, or YAML source file
    # @return [Array] the collection data
    def ingest_file(source)
      raise Error::MissingSource, "Cannot find #{source}" unless File.exist? source

      case File.extname(source)
      when '.csv'     then data = WaxTasks::Utils.validate_csv(source)
      when '.json'    then data = WaxTasks::Utils.validate_json(source)
      when /\.ya?ml/  then data = WaxTasks::Utils.validate_yaml(source)
      else raise Error::InvalidSource, "Cannot load #{File.extname(source)} files. Culprit: #{source}"
      end

      WaxTasks::Utils.assert_pids(data)
      WaxTasks::Utils.assert_unique(data)
    end
  end
end
