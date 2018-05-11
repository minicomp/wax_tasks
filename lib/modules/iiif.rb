require 'colorized_string'
require 'json'
require 'csv'
require 'yaml'
require 'wax_iiif'

# module for generating IIIF derivatives + json from local images
module Iiif
  def self.process(name, site_config)
    imgpath = "./_data/iiif/#{name}"
    abort "Source path '#{imgpath}' does not exist. Exiting.".magenta unless Dir.exist?(imgpath)

    FileUtils.mkdir_p("./iiif/#{name}", verbose: false)
    puts "#{site_config['baseurl']}/iiif/#{name}"
    builder = IiifS3::Builder.new(
      base_url: "#{site_config['baseurl']}/iiif/#{name}",
      output_dir: "./iiif/#{name}",
      verbose: true,
      variants: { med: 600, lg: 1140 }
    )

    collection_config = site_config['collections'].fetch(name, {})
    iiif_config = collection_config.fetch('iiif', {})

    opts = {
      source: collection_config.fetch('source', ''),
      label: iiif_config.fetch('label', ''),
      description: iiif_config.fetch('description', '')
    }

    builder.load(make_records(imgpath, opts))
    builder.process_data(true)
  end

  def self.make_records(imgpath, opts)
    source_data = opts[:source].empty? ? false : WaxTasks.ingest(opts[:source])
    counter = 1
    records = []

    Dir["#{imgpath}/*"].sort!.each do |imagefile|
      basename = File.basename(imagefile, '.*').to_s
      item = source_data ? source_data.find { |i| i['pid'] == basename } : false
      record_opts = { id: basename, path: imagefile }

      if item
        record_opts[:label] = item.fetch(opts[:label], basename)
        record_opts[:description] = item.fetch(opts[:description], '') unless opts[:description].empty?
      end

      counter += 1
      records << IiifS3::ImageRecord.new(record_opts)
    end
    records
  end
end
