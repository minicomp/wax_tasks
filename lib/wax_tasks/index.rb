# frozen_string_literal: true

module WaxTasks
  #
  class Index

    # Creates a new Index object
    def initialize(name, config)
      @name        = name
      @config      = config
      @collections = collections
      @records     = normalize_records

      raise WaxTasks::Error::NoSearchCollections unless @collections.first.is_a? WaxTasks::Collection
    end

    def collections
      @config.fetch('collections', [])
    end

    #
    #
    #
    def path
      @config.fetch('index')
    end

    #
    #
    #
    def normalize_records
      lunr_id = 0
      @collections.each do |collection|
        fields = DEFAULT_SEARCH_FIELDS + collection.search_fields
        fields.push('content') if collection.content?
        fields.uniq!

        collection.pagedata.map do |record|
          record.keep_only(fields)
          record.lunr_id   = lunr_id
          record.permalink = record.permalink || "/#{@name}/#{record.pid}/"
          lunr_id +=1
          record
        end
      end.flatten
    end

    #
    #
    #
    def total_fields(records)
      meta = records.map(&:meta)
      meta.map(&:keys).flatten.uniq
    end

    # @return [String] writes index as pretty JSON with YAML front-matter
    def to_s
      hashes = @records.map { |r| r.meta }
      "---\nlayout: none\n---\n#{JSON.pretty_generate(hashes)}"
    end

    #
    #
    #
    def write_to(path)
      FileUtils.mkdir_p File.dirname(path)
      File.open(path, 'w') { |f| f.write(index.to_s) }
    end
  end
end
