module WaxTasks
  # Utility helper methods
  module Utils
    # Contructs permalink extension from site `permalink` variable
    #
    # @param site [Hash] the site config
    # @return [String] the end of the permalink, either '/' or '.html'
    def self.construct_permalink(site)
      case site.fetch(:permalink, false)
      when 'pretty' || '/'
        '/'
      else
        '.html'
      end
    end

    # Checks and asserts presence of `pid` value for each item
    #
    # @param  data [Array] array of hashes each representing a collection item
    # @return [Array] same data unless a an item is missing the key `pid`
    # @raise WaxTasks::Error::MissingPid
    def self.assert_pids(data)
      data.each_with_index { |d, i| raise Error::MissingPid, "Collection #{@name} is missing pid for item #{i}." unless d.key? 'pid' }
      data
    end

    # Checks and asserts uniqueness of `pid` value for each item
    #
    # @param  data [Array] array of hashes each representing a collection item
    # @return [Array] same data unless an item has non-unique value for `pid`
    # @raise WaxTasks::Error::NonUniquePid
    def self.assert_unique(data)
      pids = data.map { |d| d['pid'] }
      not_unique = pids.select { |p| pids.count(p) > 1 }.uniq! || []
      raise Error::NonUniquePid, "#{@name} has the following nonunique pids:\n#{not_unique}" unless not_unique.empty?
      data
    end

    # Checks that a CSV file is valid
    #
    # @param  source [String] path to CSV file
    # @return [Array] validated CSV data as an Array of Hashes
    # @raise  WaxTasks::Error::InvalidCSV
    def self.validate_csv(source)
      CSV.read(source, headers: true).map(&:to_hash)
    rescue StandardError => e
      raise Error::InvalidCSV, " #{e}"
    end

    # Checks that a JSON file is valid
    #
    # @param  source [String] path to JSON file
    # @return [Array] validated JSON data as an Array of Hashes
    # @raise  WaxTasks::Error::InvalidJSON
    def self.validate_json(source)
      file = File.read(source)
      JSON.parse(file)
    rescue StandardError => e
      raise Error::InvalidJSON, " #{e}"
    end

    # Checks that a YAML file is valid
    #
    # @param  source [String] path to YAML file
    # @return [Array] validated YAML data as an Array of Hashes
    # @raise  WaxTasks::Error::InvalidYAML
    def self.validate_yaml(source)
      YAML.load_file(source)
    rescue StandardError => e
      raise WaxTasks::Error::InvalidYAML, " #{e}"
    end

    # Creates a file path valid file path with empty strings and
    # null values dropped
    #
    # @param  args [Array] items to concatenate in path
    # @return [String] file path
    def self.root_path(*args)
      ['.'].concat(args).compact.reject(&:empty?).join('/').gsub(%r{/+}, '/')
    end

    # Removes YAML front matter from a string
    # @return [String]
    def self.remove_yaml(str)
      str.to_s.gsub!(/\A---(.|\n)*?---/, '')
    end

    def self.rm_liquid(str)
      str.gsub(/{{.*}}/, '')
    end

    # Cleans YAML front matter + markdown pages for lunr indexing
    # @return [String]
    def self.html_strip(str)
      str.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
      str.gsub!(/{%(.*)%}/, '') # remove functional liquid
      str.gsub!(%r{<\/?[^>]*>}, '') # remove html
      str.gsub!('\\n', '') # remove newlines
      str.gsub!(/\s+/, ' ') # remove extra space
      str.tr!('"', "'") # replace double quotes with single
      str
    end

    # Normalizes accent marks/diacritics for Lunr indexing
    # @return [String]
    def self.remove_diacritics(str)
      to_replace  = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž'
      replaced_by = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz'
      str.to_s.tr(to_replace, replaced_by)
    end

    # Converts string to snake case and swaps out special chars
    # @return [String]
    def self.slug(str)
      str.to_s.downcase.tr(' ', '_').gsub(/[^\w-]/, '')
    end
  end
end

# Monkey-patched String class
class String
  # Normalizes string without diacritics for lunr indexing
  # @return [String]
  def lunr_normalize
    WaxTasks::Utils.remove_diacritics(self)
  end

  # Colorizes console output to magenta (errors)
  # @return [String]
  def magenta
    "\e[35m#{self}\e[0m"
  end

  # Colorizes console output to cyan (messages)
  # @return [String]
  def cyan
    "\e[36m#{self}\e[0m"
  end

  # Colorizes console output to orange (warnings)
  # @return [String]
  def orange
    "\e[33m#{self}\e[0m"
  end
end

# Monkey-patched Array class
class Array
  # Normalizes an array as a string or array of hashes
  # without diacritics for lunr indexing
  # @return [Hash || String] description
  def lunr_normalize
    if self.first.is_a? Hash
      self
    else
      WaxTasks::Utils.remove_diacritics(self.join(', '))
    end
  end

  def except(value)
    self - value
  end
end

# Monkey-patched Hash class
class Hash
  # Normalizes hash as itself for lunr indexing
  # @return [Hash]
  def lunr_normalize
    self
  end

  # Converts hash keys to symbols
  # @return [Hash]
  def symbolize_keys
    hash = self
    hash.clone.each_key do |key|
      hash[key.to_sym || key] = hash.delete(key)
    end
    hash
  end
end

# Monkey-patched Integer class
class Integer
  # Normalizes integer as a string for lunr indexing
  # @return [String]
  def lunr_normalize
    self.to_s
  end
end

# Monkey-patched Nil class
class NilClass
  # Normalizes integer as a string for lunr indexing
  # @return [String]
  def lunr_normalize
    self.to_s
  end
end
