require 'colorized_string'

def clean(str)
  str = str.gsub(/\A---(.|\n)*?---/, '') # remove yaml front matter
  str = str.gsub(/{%(.*)%}/, '') # remove functional liquid
  str = str.gsub(/<\/?[^>]*>/, '') # remove html
  str = str.gsub('\\n', '').gsub(/\s+/, ' ') # remove newlines and extra space
  str = str.tr('"', "'").to_s # replace double quotes with single
  return str
end

def valid_pagemaster(collection_name)
  if $config['collections'][collection_name].nil?
    puts "Cannot fin the collection '#{collection_name}' in _config.yml. Exiting.".magenta
    exit 1
  elsif $config['collections'][collection_name]['source'].nil?
    puts "Cannot find 'source' for the collection '#{collection_name}' in _config.yml. Exiting.".magenta
    exit 1
  elsif $config['collections'][collection_name]['layout'].nil?
    puts "Cannot find 'layout' for the collection '#{collection_name}' in _config.yml. Exiting.".magenta
    exit 1
  elsif !File.file?('_data/' + $config['collections'][collection_name]['source'])
    puts "Cannot find the file '#{'_data/' + $config['collections'][collection_name]['source']}'. Exiting.".magenta
    exit 1
  else
    return $config['collections'][collection_name]
  end
end
