module WaxTasks
  # WaxTasks utility methods
  module Utils
    # Helps contruct permalinks from config
    #
    # @param  [Hash] the site config as a hash
    # @return [String] the end of the permalink, either '/' or '.html'
    def self.construct_permalink(config)
      style = config.fetch('permalink', false)
      style == 'pretty' ? '/' : '.html'
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
  end
end

# WaxTasks monkey patching
class String
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
end

# monkey patch Integer class
class Integer
  # normalize as a string or hash without diacritics for lunr indexing
  def normalize
    self.to_s
  end
end
