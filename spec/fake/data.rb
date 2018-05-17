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
    # 3 'good' samples, one bad
    ['.json', '.csv', '.yml', '.csv'].each do |type|
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
    sample_collections = mess_one_up(collections)
    add_to_config(sample_collections)
  end

  def self.collection(name, type, data)
    {
      'source'     => "#{name}#{type}",
      'keep_order' => [true, false].sample,
      'output'     => true,
      'layout'     => 'page',
      'lunr_index' => { 'content' => [true, false].sample, 'fields' => data.first.keys },
      'iiif'       => { 'label' => data.first.keys[1], 'description' => data.first.keys[2] }
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
    5.times { keys << WaxTasks.slug(Faker::Lovecraft.unique.word) }
    3.times do |i|
      data << {
        keys[0] => i,
        keys[1] => WaxTasks.slug(Faker::Dune.character),
        keys[2] => Faker::Lorem.sentence,
        keys[3] => Faker::TwinPeaks.quote,
        keys[4] => Faker::Name.name,
        keys[5] => Faker::Lovecraft.sentence
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

  def self.mess_one_up(collections)
    k = collections.keys.last
    collections['bad'] = collections[k]
    collections.delete(k)
    source = "./_data/#{collections['bad']['source']}"
    puts source
    CSV.open(source, 'a+') { |csv| csv << [0, 'a', 'b', 'c', 'd', 'e'] }
    collections
  end

  def self.remove_bad_collection
    config = WaxTasks.site_config
    config['collections'].delete('bad')
    File.write('_config.yml', YAML.dump(config))
  end
end
