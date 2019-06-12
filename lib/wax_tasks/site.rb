# frozen_string_literal: true
require 'json'

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
    def generate_api(name)
      result     = 0
      collection = @config.find_collection name
      collection_name = collection.page_source[1..-1]
      raise WaxTasks::Error::InvalidCollection if collection.nil?
      jsonapi_settings = @config.jsonapi_settings
      raise WaxTasks::Error::InvalidJSONAPIConfig if jsonapi_settings.nil?
      jsonapi_path = "#{jsonapi_settings['prefix']}/#{collection_name}"

      collection.records_from_metadata.each do |record|
        result += record.write_to_api(jsonapi_path, jsonapi_settings)
      end

      file = jsonapi_path + '/index.json'
      unless File.exist? file
        FileUtils.mkdir_p jsonapi_path
        document = {}
        if jsonapi_settings[collection_name] && jsonapi_settings[collection_name]['meta']
          document['meta'] = jsonapi_settings[collection_name]['meta']
        end
        document['links'] = { self: '/' + jsonapi_path }
        document['data'] = collection.records_from_metadata.map do |record|
          record.jsonapi_object collection_name, "#{jsonapi_path}/#{record.pid}"
        end
        File.open(file, 'w') { |f| f.puts JSON.pretty_generate document }
      end

      puts Rainbow("#{result} entries were generated to #{jsonapi_path}.").cyan
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
