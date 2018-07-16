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
      @site[:collections].fetch(@name).symbolize_keys
    rescue StandardError => e
      raise Error::InvalidCollection, "Cannot load collection config for #{@name}.\n#{e}"
    end
  end
end
