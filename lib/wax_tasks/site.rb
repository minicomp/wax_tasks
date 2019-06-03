# frozen_string_literal: true

#
module WaxTasks
  #
  class Site
    attr_reader :config
    IMAGE_DERIVATIVE_DIRECTORY = 'img/derivatives'

    #
    #
    def initialize(config = nil)
      @config = WaxTasks::Config.new(config || WaxTasks.config_from_file)
    end

    #
    #
    def collections
      @config.collections
    end

    #
    #
    def generate_pages(name)
      result     = 0
      collection = @config.find_collection name
      raise WaxTasks::Error::InvalidCollection if collection.nil?

      collection.records_from_metadata.each do |record|
        result += record.write_to_page(collection.page_source)
      end

      puts Rainbow("#{result} pages were generated to #{collection.page_source}.").cyan
      puts Rainbow("\nDone ✔").green
    end

    #
    #
    def generate_static_search(name)
      search_config = @config.search name
      index = WaxTasks::Index.new(search_config)

      puts Rainbow("Generating #{name} search index to #{index.path}").cyan
      index.write_to @config.source

      puts Rainbow("\nDone ✔").green
    end

    #
    #
    def generate_derivatives(name, type)
      collection = @config.find_collection name
      raise WaxTasks::Error::InvalidCollection if collection.nil?
      raise WaxTasks::Error::InvalidConfig unless %w[iiif simple].include? type

      output_dir = Utils.safe_join @config.source, IMAGE_DERIVATIVE_DIRECTORY, type
      records = case type
                when 'iiif'
                  collection.write_iiif_derivatives output_dir
                when 'simple'
                  collection.write_simple_derivatives output_dir
                end

      collection.update_metadata records
      puts Rainbow("\nDone ✔").green
    end
  end
end
