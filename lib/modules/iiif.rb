require 'colorized_string'
require 'csv'
require 'json'
require 'yaml'
require 'wax_iiif'

# module for generating IIIF derivatives + json from local images
module Iiif
  def self.process(name, site_config)
    imgpath = "./_data/iiif/#{name}"
    abort "Source path '#{imgpath}' does not exist. Exiting.".magenta unless Dir.exist?(imgpath)
    FileUtils.mkdir_p("./iiif/#{name}", verbose: false)

    builder = IiifS3::Builder.new(
      base_url: "#{site_config['baseurl']}/iiif/#{name}",
      output_dir: "./iiif/#{name}",
      verbose: true,
      variants: { med: 600, lg: 1140 }
    )

    collection_config = site_config['collections'].fetch(name, {})
    opts = get_meta_opts(collection_config)
    builder.load(make_records(imgpath, opts))
    builder.process_data(true)
  end

  def self.make_records(imgpath, opts)
    records = []
    Dir["#{imgpath}/*"].sort!.each do |imagefile|
      basename = File.basename(imagefile, '.*').to_s
      record_opts = { id: basename, path: imagefile, label: basename }
      if opts
        manifest_meta = manifest_record_meta(basename, opts)
        record_opts.merge!(manifest_meta)
      end
      records << IiifS3::ImageRecord.new(record_opts)
    end
    records
  end

  def self.get_meta_opts(collection_config)
    opts = {}
    opts[:iiif_config] = collection_config.dig('iiif')
    opts[:source_data] = collection_config.key?('source') ? WaxTasks.ingest(collection_config['source']) : nil
    opts.values.all? { |v| !v.nil? } ? opts : false
  end

  def self.manifest_record_meta(basename, opts)
    manifest_meta = {}
    item = opts[:source_data] ? opts[:source_data].find { |i| i['pid'].to_s == basename } : false
    if item
      opts[:iiif_config].each { |k, v| manifest_meta[k.to_sym] = item.fetch(v, '') if item.key?(v) }
    end
    manifest_meta
  end
end
