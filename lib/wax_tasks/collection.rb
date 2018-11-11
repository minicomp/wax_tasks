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
      @config   = self.config
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
      WaxTasks::Utils.root_path(@site[:source_dir], @site[:collections_dir], "_#{@name}")
    end

    # Constructs the path to the data source file
    #
    # @return [String] the path to the data source file
    def metadata_source_path
      source = @config.dig('metadata', 'source')
      raise WaxTasks::Error::MissingSource, "Missing collection source in _config.yml for #{@name}" if source.nil?
      WaxTasks::Utils.root_path(@site[:source_dir], '_data', source)
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

    # @return [Nil]
    def overwrite_metadata
      src = self.metadata_source_path
      puts "Writing image derivative info #{src}.".cyan
      case File.extname(src)
      when '.csv'
        keys = @metadata.map(&:keys).inject(&:|)
        csv_string = keys.to_csv
        @metadata.each { |h| csv_string += h.values_at(*keys).to_csv }
        File.open(src, 'w') { |f| f.write(csv_string) }
      when '.json'
        File.open(src, 'w') { |f| f.write(JSON.pretty_generate(@metadata)) }
      when /\.ya?ml/
        File.open(src, 'w') { |f| f.write(@metadata.to_yaml) }
      else
        raise Error::InvalidSource
      end
    end
  end
end
