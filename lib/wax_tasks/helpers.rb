def clean(str)
  str.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
  str.gsub!(/{%(.*)%}/, '') # remove functional liquid
  str.gsub!(/<\/?[^>]*>/, '') # remove html
  str.gsub!('\\n', '') # remove newlines
  str.gsub!(/\s+/, ' ') # remove extra space
  str.tr!('"', "'") # replace double quotes with single
  str
end

def rm_diacritics(str)
  to_replace  = "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž"
  replaced_by = "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
  str.tr(to_replace, replaced_by)
end

def slug(str)
  str.downcase.tr(' ', '_').gsub(/[^:\w-]/, '')
end

def thing2string(thing)
  thing = thing.join(" || ") if thing.is_a?(Array)
  thing.to_s
end

def get_config
  YAML.load_file('_config.yml')
rescue StandardError
  abort 'Cannot load _config.yml'.magenta
end

def get_argv
  argv = ARGV.drop(1)
  argv.each { |a| task a.to_sym }
  argv
end
