# frozen_string_literal: true

module WaxTasks
  #
  class Index
    DEFAULT_FIELDS = %w[pid label thumbnail permalink].freeze

    # Creates a new Index object
    def initialize(config, collections)
      @config      = config
      @collections = collections
      @data        = populate(data)
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

    def total_fields(data)
      data.map(&:keys).flatten.uniq
    end

    def populate(data)
      fields = total_fields(data)
      data.each do |d|
        fields.each { |f| d[f] = d.fetch(f, '').lunr_normalize }
      end
    end

    # @return [String] writes index as pretty JSON with YAML front-matter
    def to_s
      @data.each_with_index.map { |d, i| d['lunr_id'] = i }
      "---\nlayout: none\n---\n#{JSON.pretty_generate(@data)}"
    end
  end
end
