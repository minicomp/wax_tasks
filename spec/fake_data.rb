require 'faker'
require 'csv'
require 'yaml'
require 'rake'

# make csvs
I18n.enforce_available_locales = false
Dir.mkdir('_data') unless File.exist?('_data')
collection_names = []

3.times do # 3 csv files
  csv = []
  headers = ['pid', 'title']
  6.times { headers << slug(Faker::Witcher.unique.monster) } # with 6 custom headers

  7.times do # with 7 rows
    row = {}
    row[headers[0]] = slug(Faker::Lovecraft.unique.word)
    row[headers[1]] = Faker::Lorem.sentence
    row[headers[2]] = Faker::TwinPeaks.quote
    Faker::Config.locale = 'ru'
    row[headers[3]] = Faker::Name.name
    Faker::Config.locale = 'fa'
    row[headers[4]] = Faker::Name.name
    row[headers[5]] = Faker::Commerce.product_name
    row[headers[6]] = Faker::File.file_name
    row[headers[7]] = Faker::Lovecraft.sentence
    csv << row
  end
  name = slug(Faker::Witcher.unique.monster)
  path = '_data/' + name + '.csv'
  write_csv(path, csv)
  collection_names << name
  Faker::Dune.unique.clear
  Faker::Lovecraft.unique.clear
end

# run + test wax:config
describe 'wax:config' do
  it 'accesses _config.yml and argvs' do
    load File.expand_path("../../lib/tasks/config.rake", __FILE__)
    Rake::Task['wax:config'].invoke
    expect($config.length)
  end
end

# append faker collection data to _config.yaml
load File.expand_path("../../lib/tasks/config.rake", __FILE__)
Rake::Task['wax:config'].invoke
$argv = collection_names
collection_hash = {}
collection_names.each do |name|
  collection_hash[name] = {}
  collection_hash[name]['source'] = name
  collection_hash[name]['directory'] = name
  collection_hash[name]['layout'] = 'default'
end

$config['collections'] = collection_hash
output = YAML.dump $config
File.write('_config.yml', output)
