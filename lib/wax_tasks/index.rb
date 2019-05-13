# frozen_string_literal: true

module WaxTasks
  #
  class Index
    attr_reader :path, :collections

    # Creates a new Index object
    def initialize(name, path, collections)
      @name        = name
      @path        = path
      @collections = collections
      @records     = records
    end

    #
    #
    #
    def records
      lunr_id = 0
      records = []
      @collections.each do |collection|
        collection.page_records.each do |record|
          record.keep_only(collection.search_fields)
          record.lunr_id   = lunr_id
          record.permalink = record.permalink || "/#{@name}/#{record.pid}/"
          lunr_id += 1
          records << record
        end
      end
      records
    end

    #
    #
    #
    def total_fields(records)
      meta = records.map(&:meta)
      meta.map(&:keys).flatten.uniq
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
