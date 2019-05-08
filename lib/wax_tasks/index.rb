# frozen_string_literal: true

module WaxTasks
  #
  class Index
    DEFAULT_FIELDS = %w[pid label thumbnail].freeze

    # Creates a new Index object
    def initialize(config, collections)
      @config      = config
      @collections = collections
      @data        = data
    end

    def path
      @path || @config.fetch('index')
    end

    def data
      @config['collections'].map do |c|
        name       = c[0]
        collection = @collections.find { |i| i.name == name }
        fields     = DEFAULT_FIELDS + c[1].fetch('fields', [])

        fields.push('content') if c[1].dig('content')

        collection.pagedata.map do |item|
          i = item.keep_if { |k,| fields.include? k }
          i['collection'] = name
          i['permalink']  = item.fetch('permalink', "/#{name}/#{item['pid']}/")
          i
        end
      end.flatten
    end

    # @return [String] writes index as pretty JSON with YAML front-matter
    def to_s
      @data.each_with_index.map { |d, i| d['lunr_id'] = i }
      "---\nlayout: none\n---\n#{JSON.pretty_generate(@data)}"
    end
  end
end
