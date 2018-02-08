require 'csv'
require 'faker'
require 'json'
require 'rake'

# make csvs
I18n.enforce_available_locales = false
Faker::Config.locale = 'zh-CN'
Dir.mkdir('_data') unless File.exist?('_data')

def fake_data(name, type)
  data = []
  keys = ['pid']
  5.times { keys << slug(Faker::Lovecraft.unique.word) } # keys = pid + 5
  5.times do # with 5 records
    record = {
      keys[0] => slug(Faker::Dune.unique.character),
      keys[1] => Faker::Lorem.sentence,
      keys[2] => Faker::TwinPeaks.quote,
      keys[3] => Faker::Name.name,
      keys[4] => Faker::Space.star,
      keys[5] => Faker::Lovecraft.sentence
    }
    data << record
    $collection_data[name] = { 'keys' => keys, 'type' => type }
  end
  data
end

5.times do |i|
  name = slug(Faker::RuPaul.unique.queen)
  if i.even?
    data = fake_data(name, '.csv')
    path = '_data/' + name + '.csv'
    write_csv(path, data)
  else
    data = fake_data(name, '.json')
    path = '_data/' + name + '.json'
    File.open(path, 'w') { |f| f.write(data.to_json) }
  end
  Faker::Dune.unique.clear
  Faker::Lovecraft.unique.clear
end
