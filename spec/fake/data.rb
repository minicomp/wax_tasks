require 'faker'

# make csvs and json, set up metadata to use in testing tasks
module Fake
  def self.data
    # generate
    collections = [
      DataFile.new(ext: '.csv', iiif: true),
      DataFile.new(ext: '.yml', nested: true),
      DataFile.new(ext: '.json', nested: true, iiif: true)
    ]
    add_to_config(collections)
    collections.each(&:write)
  end

  def self.add_to_config(collections)
    site_config = YAML.load_file('_config.yml')
    collections_config = {}
    collections.each { |c| collections_config[c.name] = c.config }
    site_config['collections'] = collections_config
    File.write('_config.yml', YAML.dump(site_config))
  end

  def self.content(pages)
    pages.each do |page|
      File.open(page, 'a') { |f| f.puts "\n#{Faker::Markdown.random}\n" }
    end
  end

  class DataFile
    attr_reader :name, :config

    def initialize(opts = {})
      @extension  = opts.fetch(:ext, nil)
      @nested     = opts.fetch(:nested, false)
      @iiif       = opts.fetch(:iiif, false)
      @name       = new_name
      @data       = generate_data
      @config     = collection_config
    end

    def new_name
      name = slug(Faker::Dune.unique.character)
      name += '-nested' if @nested
      name
    end

    def write
      path = "_data/#{@name}#{@extension}"
      case @extension
      when '.csv' then write_csv(path, @data)
      when '.json' then write_json(path, @data)
      when '.yml' then write_yaml(path, @data)
      end
    end

    def collection_config
      c_conf = {
        'source'      => "#{@name}#{@extension}",
        'keep_order'  => [true, false].sample,
        'output'      => true,
        'layout'      => 'page',
        'lunr_index'  => {
          'content'   => [true, false].sample,
          'fields'    => @data.first.keys
        }
      }
      if @iiif
        c_conf['iiif'] = {
          'meta' => {
            'label' => @data.first.keys[1],
            'description' => @data.first.keys[2]
          },
          'variants' => [100, 900]
        }
      end
      c_conf
    end

    def generate_data
      data = []
      keys = ['pid']
      5.times { keys << slug(Faker::Lovecraft.unique.word) }
      3.times { |i| data << generate_row(keys, i) }
      data
    end

    def generate_row(keys, i)
      row = {
        keys[0] => i,
        keys[1] => slug(Faker::Dune.character),
        keys[2] => Faker::TwinPeaks.quote,
        keys[3] => Faker::Lovecraft.sentence,
        keys[4] => Faker::Name.name
      }
      if @nested
        row[keys[4]] = { '1' => Faker::Name.name, '2' => Faker::Name.name }
      end
      row
    end

    def write_csv(path, hashes)
      CSV.open(path, 'wb:UTF-8') do |csv|
        csv << hashes.first.keys
        hashes.each do |hash|
          csv << hash.values
        end
      end
    end

    def write_json(path, data)
      File.open(path, 'w') { |f| f.write(data.to_json) }
    end

    def write_yaml(path, data)
      File.open(path, 'w') { |f| f.write(YAML.dump(data)) }
    end
  end
end
