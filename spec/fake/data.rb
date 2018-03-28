require 'csv'
require 'faker'
require 'json'
require 'rake'

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'wax_tasks'

# make csvs and json, set up metadata to use in testing tasks
module Fake
  def self.data
    I18n.enforce_available_locales = false
    Faker::Config.locale = 'zh-CN'
    collections = {}
    [".json", ".csv", ".yml"].each do |type|
      data = generate_data
      name = WaxTasks.slug(Faker::RuPaul.unique.queen)
      keys = data.first.keys
      path = "_data/#{name}#{type}"
      collections[name] = {
        'source'     => "#{name}#{type}",
        'output'     => true,
        'layout'     => 'page',
        'lunr_index' => { 'content' => false, 'fields' => keys }
      }
      case type
      when '.csv' then write_csv(path, data)
      when '.json' then File.open(path, 'w') { |f| f.write(data.to_json) }
      when '.yml' then File.open(path, 'w') { |f| f.write(YAML.dump(data)) }
      end
    end
    config = WaxTasks.config
    config['collections'] = collections
    File.write('_config.yml', YAML.dump(config))
  end

  def self.generate_data
    data = []
    keys = ['pid']
    5.times { keys << WaxTasks.slug(Faker::Lovecraft.unique.word) } # keys = pid + 5
    3.times do # with 3 records
      record = {
        keys[0] => WaxTasks.slug(Faker::Dune.unique.character),
        keys[1] => Faker::Lorem.sentence,
        keys[2] => Faker::TwinPeaks.quote,
        keys[3] => Faker::Name.name,
        keys[4] => Faker::Space.star,
        keys[5] => Faker::Lovecraft.sentence
      }
      data << record
    end
    data
  end

  def self.write_csv(path, hashes)
    CSV.open(path, 'wb:UTF-8') do |csv|
      csv << hashes.first.keys
      hashes.each do |hash|
        csv << hash.values
      end
    end
  rescue StandardError
    abort "Cannot write csv data to #{path} for some reason.".magenta
  end
end
