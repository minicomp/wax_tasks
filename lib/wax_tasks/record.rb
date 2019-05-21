# frozen_string_literal: true

module WaxTasks
  #
  class Record
    attr_reader :pid, :hash

    def initialize(hash)
      @hash = hash
      @pid  = hash.dig 'pid'
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
  end
end
