# frozen_string_literal: true

module WaxTasks
  #
  class Index
    attr_reader :path, :collections

    def initialize(config)
      @config      = config
      @collections = config.dig 'collections'
      @path        = config.dig 'index'

      raise WaxTasks::Error::NoSearchCollections if @collections.nil?
      raise WaxTasks::Error::InvalidConfig if @path.nil?

      @records = records
    end

    #
    #
    def records
      lunr_id = 0
      @collections.flat_map do |collection|
        collection.records_from_pages.each.flat_map do |r|
          r.keep_only collection.search_fields
          r.set 'lunr_id', lunr_id
          r.lunr_normalize_values
          lunr_id += 1
          r
        end
      end
    end

    #
    #
    def write_to(dir)
      file_path = WaxTasks::Utils.safe_join dir, @path
      FileUtils.mkdir_p File.dirname(file_path)
      File.open(file_path, 'w') do |f|
        f.puts "---\nlayout: none\n---\n"
        f.puts JSON.pretty_generate(@records.map(&:hash))
      end
    end
  end
end
