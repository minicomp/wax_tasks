# frozen_string_literal: true

module WaxTasks
  # Utility helper methods
  module Utils
    #
    #
    #
    def self.ingest(source)
      case File.extname(source)
      when '.csv'
        WaxTasks::Utils.validate_csv(source)
      when '.json'
        WaxTasks::Utils.validate_json(source)
      when /\.ya?ml/
        WaxTasks::Utils.validate_yaml(source)
      else
        raise Error::InvalidSource, "Can't load #{File.extname(source)} files. Culprit: #{source}"
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
      Utils.remove_diacritics(str).to_s.downcase.tr(' ', '_').gsub(/[^\w-]/, '')
    end

    #
    #
    def self.safe_join(*args)
      File.join(args.compact)
    end

    # Constructs the order variable for each page (if the collection
    # needs to preserve the order of items from the file)
    #
    # @return [Integer] the order if the item padded with '0's for sorting
    def self.padded_int(idx, max_idx)
      idx.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
    end

    #
    #
    #
    def self.process_pdf(path)
      target_dir = path.gsub('.pdf', '')
      return unless Dir.glob("#{target_dir}/*").empty?

      puts Rainbow("\nPreprocessing #{path} into image files. This may take a minute.\n").cyan
      opts = { output_dir: File.dirname(target_dir) }
      WaxIiif::Utilities::PdfSplitter.split(path, opts).sort
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
end

# Monkey-patched Hash class
class Hash
  # Normalizes hash as itself for lunr indexing
  # @return [Hash]
  def lunr_normalize
    self
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
