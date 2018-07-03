# WaxTasks utility methods
module WaxTasks
  module Utils
    # Helps contruct permalinks from config
    #
    # @param  [Hash] the site config as a hash
    # @return [String] the end of the permalink, either '/' or '.html'
    def self.construct_permalink(config)
      style = config.fetch('permalink', false)
      style == 'pretty' ? '/' : '.html'
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

class Array
  # normalize as a string or hash without diacritics for lunr indexing
  def normalize
    if self.first.is_a? Hash then self ;
    else self.join(', ').remove_diacritics
    end
  end
end

class Hash
  # normalize as a string or hash without diacritics for lunr indexing
  def normalize
    self
  end
end

class Integer
  # normalize as a string or hash without diacritics for lunr indexing
  def normalize
    self.to_s
  end
end
