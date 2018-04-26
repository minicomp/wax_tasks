require 'json'
require 'wax_iiif'

# module for generating IIIF derivatives + json from local images
module Iiif
  include FileUtils

  def self.ingest_collections(args, site_config)
    mkdir_p('./iiif', :verbose => false)
    all_records = []
    id_counter = 0
    build_opts = Iiif.build_options(site_config)
    args.each do |a|
      id_counter += 1
      inpath = './_data/iiif/' + a
      abort "Source path '#{inpath}' does not exist. Exiting.".magenta unless Dir.exist?(inpath)
      collection_records = make_records(a, inpath)
      all_records.concat collection_records
    end
    builder = IiifS3::Builder.new(build_opts)
    builder.load(all_records)
    builder.process_data(true)
  end

  def self.build_options(site_config)
    {
      :base_url => site_config['baseurl'] + '/iiif',
      :output_dir => './iiif',
      :verbose => true,
      :variants => { 'med' => 600, 'lg' => 1140 }
    }
  end

  def self.make_records(arg, inpath)
    counter = 1
    records = []
    imagefiles = Dir[inpath + '/*'].sort!
    imagefiles.each do |imagefile|
      basename = File.basename(imagefile, '.*').to_s
      record_opts = {
        :id => arg + '-' + basename,
        :path => imagefile,
        :label => arg + ' - ' + basename
      }
      counter += 1
      records << IiifS3::ImageRecord.new(record_opts)
    end
    records
  end
end
