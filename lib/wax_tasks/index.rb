# frozen_string_literal: true

module WaxTasks
  #
  class Index
    attr_reader :path, :collections

    # Creates a new Index object
    def initialize(config)
      @config      = config
      @collections = config.fetch('collections')
      @path        = config.fetch('index_file')
      @records     = records
    end

    #
    #
    #
    def records
      lunr_id = 0
      @collections.flat_map do |collection|
        collection.records_from_pages.each.flat_map do |record|
          record.keep_only(collection.search_fields)
          record.set('lunr_id', lunr_id)
          record.lunr_normalize_values
          lunr_id += 1
          record
        end
      end
    end

    #
    #
    #
    def write_to(dir)
      file_path = WaxTasks::Utils.safe_join(dir, path)
      FileUtils.mkdir_p File.dirname(file_path)
      File.open(file_path, 'w') do |f|
        f.puts "---\nlayout: none\n---\n"
        f.puts JSON.pretty_generate(@records.map(&:hash))
      end
    end
  end
end
