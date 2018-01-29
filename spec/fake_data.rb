require 'csv'
require 'faker'
require 'json'
require 'rake'

# make csvs
I18n.enforce_available_locales = false
Dir.mkdir('_data') unless File.exist?('_data')

2.times do # 2 csv files + 2 json files
  data = []
  csv_name = slug(Faker::Witcher.unique.monster)
  json_name = slug(Faker::RuPaul.unique.queen)
  pids = []
  keys = ['pid', 'title']
  5.times { keys << slug(Faker::Space.unique.star) } # with 6 custom keys
  5.times do # with 5 records
    record = {}
    pid = slug(Faker::Lovecraft.unique.word)
    pids << pid
    record[keys[0]] = pid
    record[keys[1]] = Faker::Lorem.sentence
    record[keys[2]] = Faker::TwinPeaks.quote
    Faker::Config.locale = 'ru'
    record[keys[3]] = Faker::Name.name
    Faker::Config.locale = 'fa'
    record[keys[4]] = Faker::Name.name
    record[keys[5]] = Faker::File.file_name
    record[keys[6]] = Faker::Lovecraft.sentence
    data << record
  end
  csv_path = '_data/' + csv_name + '.csv'
  json_path = '_data/' + json_name + '.json'
  write_csv(csv_path, data)
  File.open(json_path, 'w') { |f| f.write(data.to_json) }
  $collection_data[csv_name] = { 'keys' => keys, 'pids' => pids, 'type' => '.csv' }
  $collection_data[json_name] = { 'keys' => keys, 'pids' => pids, 'type' => '.json' }
  Faker::Dune.unique.clear
  Faker::Lovecraft.unique.clear
end
