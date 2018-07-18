# document
module WaxTasks
  # Utility methods
  module Utils
    # Helps contruct permalinks from config
    #
    # @param  [Hash] the site config as a hash
    # @return [String] the end of the permalink, either '/' or '.html'
    def self.construct_permalink(config)
      case config.fetch(:permalink, false)
      when 'pretty' || '/'
        '/'
      else
        '.html'
      end
    end

    def self.assert_pids(data)
      data.each_with_index { |d, i| raise Error::MissingPid, "Collection #{@name} is missing pid for item #{i}." unless d.key? 'pid' }
      data
    end

    def self.assert_unique(data)
      pids = data.map { |d| d['pid'] }
      not_unique = pids.select { |p| pids.count(p) > 1 }.uniq! || []
      raise Error::NonUniquePid, "#{@name} has the following nonunique pids:\n#{not_unique}" unless not_unique.empty?
      data
    end

    def self.validate_csv(source)
      CSV.read(source, headers: true).map(&:to_hash)
    rescue StandardError => e
      raise Error::InvalidCSV, " #{e}"
    end

    def self.validate_json(source)
      file = File.read(source)
      JSON.parse(file)
    rescue StandardError => e
      raise Error::InvalidJSON, " #{e}"
    end

    def self.validate_yaml(source)
      YAML.load_file(source)
    rescue StandardError => e
      raise WaxTasks::Error::InvalidYAML, " #{e}"
    end

    def self.make_path(*args)
      args.compact.reject(&:empty?).join('/')
    end

    def self.get_lunr_collections(site)
      to_index = site[:collections].find_all { |c| c[1].key?('lunr_index') }
      raise Error::NoLunrCollections, 'There are no lunr collections to index.' if to_index.nil?
      to_index.map { |c| c[0] }
    end
  end
end

# WaxTasks monkey patching
class String
  def remove_yaml
    self.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
  end

  # cleans yaml + markdown pages for lunr indexing
  def html_strip
    self.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
    self.gsub!(/{%(.*)%}/, '') # remove functional liquid
    self.gsub!(%r{<\/?[^>]*>}, '') # remove html
    self.gsub!('\\n', '') # remove newlines
    self.gsub!(/\s+/, ' ') # remove extra space
    self.tr!('"', "'") # replace double quotes with single
    self
  end

  # normalizes accents for lunr indexing
  def remove_diacritics
    to_replace  = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž'
    replaced_by = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz'
    self.tr(to_replace, replaced_by)
  end

  # converts string to snake case and swaps out special chars
  def slug
    self.downcase.tr(' ', '_').gsub(/[^\w-]/, '')
  end

  # normalize as a string or hash without diacritics for lunr indexing
  def normalize
    self.remove_diacritics
  end
end

# monkey patch Array class
class Array
  # normalize as a string or hash without diacritics for lunr indexing
  def normalize
    if self.first.is_a? Hash
      self
    else
      self.join(', ').remove_diacritics
    end
  end
end

# monkey patch Hash class
class Hash
  # normalize as a string or hash without diacritics for lunr indexing
  def normalize
    self
  end

  def symbolize_keys
    hash = self
    hash.keys.each do |key|
      hash[key.to_sym || key] = hash.delete(key)
    end
    hash
  end
end

# monkey patch Integer class
class Integer
  # normalize as a string or hash without diacritics for lunr indexing
  def normalize
    self.to_s
  end
end
