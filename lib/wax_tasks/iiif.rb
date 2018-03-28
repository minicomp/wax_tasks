require 'json'
require 'wax_iiif'


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
    builder.process_data
  end

  def self.build_options(site_config)
    {
      :base_url => site_config['baseurl'] + '/iiif',
      :output_dir => './iiif',
      :verbose => true
    }
  end

  def self.make_records(a, inpath)
    counter = 1
    records = []
    imagefiles = Dir[inpath + '/*'].sort!
    imagefiles.each do |imagefile|
      basename = File.basename(imagefile, '.*').to_s
      record_opts = {
        :id => a + '-' + basename,
        :path => imagefile,
        :label => a + ' - ' + basename
      }
      counter += 1
      records << IiifS3::ImageRecord.new(record_opts)
    end
    records
  end
end
