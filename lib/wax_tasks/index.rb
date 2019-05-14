# frozen_string_literal: true

module WaxTasks
  #
  class Index
    attr_reader :path, :collections

    # Creates a new Index object
    def initialize(name, config, collections)
      @name        = name
      @config      = config
      @collections = collections
      @path        = config.index_file
      @records     = records
    end

    #
    #
    #
    def records
      lunr_id = 0
      records = []
      @collections.each do |collection|
        collection.records_from_pages.each do |record|
          record.keep_only(collection.search_fields)
          record.lunr_id   = lunr_id
          record.permalink = record.permalink || "/#{@name}/#{record.pid}/"
          record.lunr_normalize_values
          lunr_id += 1
          records << record
        end
      end
      records
    end

    #
    #
    #
    def write_to(dir)
      file_path = WaxTasks::Utils.safe_join(dir, path)
      FileUtils.mkdir_p File.dirname(file_path)
      File.open(file_path, 'w') do |f|
        f.puts("---\nlayout: none\n---\n")
        f.puts(JSON.pretty_generate(@records.map(&:meta)))
      end
    end
  end
end
