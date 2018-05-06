require 'colorized_string'
require 'json'
require 'wax_iiif'

# module for generating IIIF derivatives + json from local images
module Iiif
  def self.process(name, site_config)
    inpath = "./_data/iiif/#{name}"
    unless Dir.exist?(inpath)
      abort "Source path '#{inpath}' does not exist. Exiting.".magenta
    end
    FileUtils.mkdir_p("./iiif/#{name}", verbose: false)
    build_opts = {
      base_url: "#{site_config['baseurl']}/iiif",
      output_dir: "./iiif/#{name}",
      verbose: true,
      variants: { med: 600, lg: 1140 }
    }
    builder = IiifS3::Builder.new(build_opts)
    builder.load(make_records(name, inpath))
    builder.process_data(true)
  end

  def self.make_records(name, inpath)
    counter = 1
    records = []
    Dir["#{inpath}/*"].sort!.each do |imagefile|
      basename = File.basename(imagefile, '.*').to_s
      record_opts = {
        id: basename,
        path: imagefile,
        label: "#{name} #{basename}"
      }
      counter += 1
      records << IiifS3::ImageRecord.new(record_opts)
    end
    records
  end
end
