require 'csv'
require 'faker'
require 'json'
require 'rake'

$LOAD_PATH.unshift File.expand_path('../../lib', __dir__)
require 'wax_tasks'

# make csvs and json, set up metadata to use in testing tasks
module Fake
  def self.data
    collections = {}
    ['.json', '.csv', '.yml'].each do |type|
      name = WaxTasks.slug(Faker::Dune.unique.character)
      data = generate_data
      collections[name] = collection(name, type, data)
      path = "_data/#{name}#{type}"
      case type
      when '.csv' then write_csv(path, data)
      when '.json' then write_json(path, data)
      when '.yml' then write_yaml(path, data)
      end
    end
    add_to_config(collections)
  end

  def self.collection(name, type, data)
    {
      'source'     => "#{name}#{type}",
      'keep_order' => [true, false].sample,
      'output'     => true,
      'layout'     => 'page',
      'lunr_index' => { 'content' => [true, false].sample, 'fields' => data.first.keys }
    }
  end

  def self.add_to_config(collections)
    config = WaxTasks.site_config
    config['collections'] = collections
    File.write('_config.yml', YAML.dump(config))
  end

  def self.generate_data
    data = []
    keys = ['pid']
    4.times { keys << WaxTasks.slug(Faker::Lovecraft.unique.word) }
    3.times do
      data << {
        keys[0] => WaxTasks.slug(Faker::Dune.unique.character),
        keys[1] => Faker::Lorem.sentence,
        keys[2] => Faker::TwinPeaks.quote,
        keys[3] => Faker::Name.name,
        keys[4] => Faker::Lovecraft.sentence
      }
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
  end

  def self.write_json(path, data)
    File.open(path, 'w') { |f| f.write(data.to_json) }
  end

  def self.write_yaml(path, data)
    File.open(path, 'w') { |f| f.write(YAML.dump(data)) }
  end

  def self.content(pages)
    pages.each do |page|
      File.open(page, 'a') { |f| f.puts "\n#{Faker::Markdown.random}\n" }
    end
  end
end
