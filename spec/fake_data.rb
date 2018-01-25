require 'csv'
require 'faker'
require 'rake'

# make csvs
I18n.enforce_available_locales = false
Dir.mkdir('_data') unless File.exist?('_data')

3.times do # 3 csv files
  csv = []
  name = slug(Faker::Witcher.unique.monster)
  pids = []
  headers = ['pid', 'title']
  5.times { headers << slug(Faker::Witcher.unique.monster) } # with 6 custom headers
  5.times do # with 5 rows
    row = {}
    pid = slug(Faker::Lovecraft.unique.word)
    pids << pid
    row[headers[0]] = pid
    row[headers[1]] = Faker::Lorem.sentence
    row[headers[2]] = Faker::TwinPeaks.quote
    Faker::Config.locale = 'ru'
    row[headers[3]] = Faker::Name.name
    Faker::Config.locale = 'fa'
    row[headers[4]] = Faker::Name.name
    row[headers[5]] = Faker::File.file_name
    row[headers[6]] = Faker::Lovecraft.sentence
    csv << row
  end
  path = '_data/' + name + '.csv'
  write_csv(path, csv)
  $collection_data[name] = {
    'headers' => headers,
    'pids' => pids
  }
  Faker::Dune.unique.clear
  Faker::Lovecraft.unique.clear
end
