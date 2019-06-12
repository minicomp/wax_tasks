# frozen_string_literal: true
require 'json'

module WaxTasks
  #
  class Record
    attr_reader :pid, :hash, :order

    def initialize(hash)
      @hash  = hash
      @pid   = @hash.dig 'pid'
      @order = @hash.dig 'order'
    end

    #
    #
    def lunr_normalize_values
      @hash.transform_values { |v| Utils.lunr_normalize v }
    end

    #
    #
    def keys
      @hash.keys
    end

    #
    #
    def set(key, value)
      @hash[key] = value
    end

    #
    #
    def permalink?
      @hash.key? 'permalink'
    end

    #
    #
    def order?
      @order.is_a? String
    end

    #
    #
    def keep_only(fields)
      @hash.select! { |k, _v| fields.include? k }
    end

    #
    #
    def write_to_page(dir)
      raise Error::MissingPid if @pid.nil?

      path = "#{dir}/#{Utils.slug(@pid)}.md"
      if File.exist? path
        0
      else
        FileUtils.mkdir_p File.dirname(path)
        File.open(path, 'w') { |f| f.puts "#{@hash.to_yaml}---" }
        1
      end
    end

    #
    #
    def write_to_api(dir, jsonapi_settings)
      raise Error::MissingPid if @pid.nil?

      collection_name = @hash['collection']
      path = "#{dir}/#{Utils.slug(@pid)}/"
      file = path + 'index.json'
      if File.exist? file
        0
      else
        FileUtils.mkdir_p path
        document = {}
        if jsonapi_settings[collection_name] && jsonapi_settings[collection_name]['meta']
          document['meta'] = jsonapi_settings[collection_name]['meta']
        end
        document['data'] = jsonapi_object collection_name, path
        File.open(file, 'w') { |f| f.puts JSON.pretty_generate document }
        1
      end
    end

    #
    #
    def jsonapi_object(collection_name, path)
      {
        id: @pid,
        type: collection_name,
        attributes: @hash,
        links: {
          self: '/' + path
        }
      }
    end
  end
end
