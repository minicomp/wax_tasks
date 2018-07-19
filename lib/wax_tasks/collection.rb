# document
module WaxTasks
  # comment
  class Collection
    attr_reader :name, :page_dir

    def initialize(name, site)
      @name     = name
      @site     = site
      @config   = collection_config
      @page_dir = Utils.make_path(@site[:source_dir],
                                  @site[:collections_dir],
                                  @name)
    end

    def collection_config
      @site[:collections].fetch(@name)
    rescue StandardError => e
      raise Error::InvalidCollection, "Cannot load collection config for #{@name}.\n#{e}"
    end

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
