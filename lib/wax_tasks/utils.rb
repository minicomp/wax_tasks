# frozen_string_literal: true

module WaxTasks
  # Utility helper methods
  module Utils
    #
    #
    def self.ingest(source)
      metadata =  case File.extname source
                  when '.csv'
                    WaxTasks::Utils.validate_csv source
                  when '.json'
                    WaxTasks::Utils.validate_json source
                  when /\.ya?ml/
                    WaxTasks::Utils.validate_yaml source
                  else
                    raise Error::InvalidSource, "Can't load #{File.extname source} files. Culprit: #{source}"
                  end

      WaxTasks::Utils.assert_pids metadata
      WaxTasks::Utils.assert_unique metadata
    end

    # Checks and asserts presence of `pid` value for each item
    #
    # @param  data [Array] array of hashes each representing a collection item
    # @return [Array] same data unless a an item is missing the key `pid`
    # @raise WaxTasks::Error::MissingPid
    def self.assert_pids(data)
      data.each_with_index { |d, i| raise Error::MissingPid, "Collection is missing pid for item #{i}.\nHint: review common .csv formatting issues (such as hidden characters) in the documentation: https://minicomp.github.io/wiki/wax/preparing-your-collection-data/metadata/" unless d.key? 'pid' }
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
      file = File.read source
      JSON.parse file
    rescue StandardError => e
      raise Error::InvalidJSON, " #{e}"
    end

    # Checks that a YAML file is valid
    #
    # @param  source [String] path to YAML file
    # @return [Array] validated YAML data as an Array of Hashes
    # @raise  WaxTasks::Error::InvalidYAML
    def self.validate_yaml(source)
      SafeYAML.load_file source
    rescue StandardError => e
      raise WaxTasks::Error::InvalidYAML, " #{e}"
    end

    # Removes YAML front matter from a string
    # @return [String]
    def self.remove_yaml(str)
      str.to_s.gsub!(/\A---(.|\n)*?---/, '')
    end

    # Scrubs yaml, liquid, html, and etc from content strings
    # @return [String]
    def self.content_clean(str)
      str.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
      str.gsub!(/{%(.*)%}/, '') # remove functional liquid
      str.gsub!(/{{.*}}/, '') # remove referential liquid
      str.gsub!(%r{</?[^>]*>}, '') # remove html
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
      str.to_s.tr to_replace, replaced_by
    end

    # Converts string to snake case and swaps out special chars
    # @return [String]
    def self.slug(str)
      Utils.remove_diacritics(str).to_s.downcase.tr(' ', '_').gsub(/[^\w-]/, '')
    end

    #
    #
    def self.safe_join(*args)
      File.join(args.compact).sub %r{^/}, ''
    end

    # Constructs the order variable for each page (if the collection
    # needs to preserve the order of items from the file)
    #
    # @return [Integer] the order if the item padded with '0's for sorting
    def self.padded_int(idx, max_idx)
      idx.to_s.rjust(Math.log10(max_idx).to_i + 1, '0')
    end

    def self.lunr_normalize(val)
      case val
      when String || Integer
        WaxTasks::Utils.remove_diacritics val.to_s
      when Array
        return val if val.first.is_a? Hash
        WaxTasks::Utils.remove_diacritics val.join(', ')
      else
        val
      end
    end

    def self.add_yaml_front_matter_to_file(file)
      front_matter = "---\nlayout: none\n---\n"
      filestring = File.read file
      return if filestring.start_with? front_matter

      File.open(file, 'w') do |f|
        f.puts front_matter
        f.puts filestring
      end
    end
  end
end
