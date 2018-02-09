def clean(str)
  str.gsub!(/\A---(.|\n)*?---/, '') # remove yaml front matter
  str.gsub!(/{%(.*)%}/, '') # remove functional liquid
  str.gsub!(/<\/?[^>]*>/, '') # remove html
  str.gsub!('\\n', '') # remove newlines
  str.gsub!(/\s+/, ' ') # remove extra space
  str.tr!('"', "'") # replace double quotes with single
  str
end

def valid_pagemaster(collection_name)
  c = $config.fetch('collections').fetch(collection_name)
  abort "Cannot find 'source' for the collection '#{collection_name}' in _config.yml. Exiting.".magenta if c.fetch('source').nil?
  abort "Cannot find 'layout' for the collection '#{collection_name}' in _config.yml. Exiting.".magenta if c.fetch('layout').nil?
  abort "Cannot find the file '#{'_data/' + c['source']}'. Exiting.".magenta unless File.file?('_data/' + c.fetch('source'))
  c
end

def rm_diacritics(str)
  to_replace  = "ÀÁÂÃÄÅàáâãäåĀāĂăĄąÇçĆćĈĉĊċČčÐðĎďĐđÈÉÊËèéêëĒēĔĕĖėĘęĚěĜĝĞğĠġĢģĤĥĦħÌÍÎÏìíîïĨĩĪīĬĭĮįİıĴĵĶķĸĹĺĻļĽľĿŀŁłÑñŃńŅņŇňŉŊŋÒÓÔÕÖØòóôõöøŌōŎŏŐőŔŕŖŗŘřŚśŜŝŞşŠšſŢţŤťŦŧÙÚÛÜùúûüŨũŪūŬŭŮůŰűŲųŴŵÝýÿŶŷŸŹźŻżŽž"
  replaced_by = "AAAAAAaaaaaaAaAaAaCcCcCcCcCcDdDdDdEEEEeeeeEeEeEeEeEeGgGgGgGgHhHhIIIIiiiiIiIiIiIiIiJjKkkLlLlLlLlLlNnNnNnNnnNnOOOOOOooooooOoOoOoRrRrRrSsSsSsSssTtTtTtUUUUuuuuUuUuUuUuUuUuWwYyyYyYZzZzZz"
  str.tr(to_replace, replaced_by)
end

def slug(str)
  str.downcase.tr(' ', '_').gsub(/[^\w-]/, '')
end
