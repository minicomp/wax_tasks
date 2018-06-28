require 'colorize'

require_relative 'utils/error'
require_relative 'utils/message'

# WaxTasks utilities
module Utils
  include Error
  include Message

  # normalizes accents for lunr indexing
  def self.rm_diacritics(str)
    to_replace  = 'ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž'
    replaced_by = 'AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz'
    str.tr(to_replace, replaced_by)
  end

  # cleans yaml + markdown pages for lunr indexing
  def self.clean(str)
    str.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
    str.gsub!(/{%(.*)%}/, '') # remove functional liquid
    str.gsub!(%r{<\/?[^>]*>}, '') # remove html
    str.gsub!('\\n', '') # remove newlines
    str.gsub!(/\s+/, ' ') # remove extra space
    str.tr!('"', "'") # replace double quotes with single
    str
  end

  def self.slug(str)
    str.downcase.tr(' ', '_').gsub(/[^:\w-]/, '')
  end

  def self.construct_permalink
    perma = WaxTasks::CONFIG_FILE.fetch('permalink', false)
    perma == 'pretty' ? '/' : '.html'
  end
end
