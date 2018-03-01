require 'csv'
require 'faker'
require 'json'
require 'rake'

# make csvs and json, set up metadata to use in testing tasks
module Fake
  def self.data
    I18n.enforce_available_locales = false
    Faker::Config.locale = 'zh-CN'
    collection_data = {}
    3.times do |i|
      name = slug(Faker::RuPaul.unique.queen)
      if i.even?
        data = generate_data(name, '.csv', collection_data)
        path = '_data/' + name + '.csv'
        write_csv(path, data)
        puts "Writing csv data to #{path}."
      else
        data = generate_data(name, '.json', collection_data)
        path = '_data/' + name + '.json'
        File.open(path, 'w') { |f| f.write(data.to_json) }
        puts "Writing json data to #{path}."
      end
      Faker::Dune.unique.clear
      Faker::Lovecraft.unique.clear
    end
    collection_data
  end

  def self.generate_data(name, type, collection_data)
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
      collection_data[name] = { 'keys' => keys, 'type' => type }
    end
    data
  end
end
