require 'colorized_string'
require 'json'
require 'wax_iiif'

require 'wax_tasks'

# module for generating IIIF derivatives + json from local images
module Iiif
  def self.process(names)
    FileUtils.mkdir_p('./iiif', verbose: false)
    all_records = []
    id_counter = 0
    build_opts = Iiif.build_options(WaxTasks.site_config)
    names.each do |name|
      id_counter += 1
      inpath = './_data/iiif/' + name
      unless Dir.exist?(inpath)
        abort "Source path '#{inpath}' does not exist. Exiting.".magenta
      end
      collection_records = make_records(name, inpath)
      all_records.concat collection_records
    end
    builder = IiifS3::Builder.new(build_opts)
    builder.load(all_records)
    builder.process_data(true)
  end

  def self.build_options(site_config)
    {
      base_url: site_config['baseurl'].to_s + '/iiif',
      output_dir: './iiif',
      verbose: true,
      variants: { med: 600, lg: 1140 }
    }
  end

  def self.make_records(name, inpath)
    counter = 1
    records = []
    imagefiles = Dir[inpath + '/*'].sort!
    imagefiles.each do |imagefile|
      basename = File.basename(imagefile, '.*').to_s
      record_opts = {
        id: name + '-' + basename,
        path: imagefile,
        label: name + ' - ' + basename
      }
      counter += 1
      records << IiifS3::ImageRecord.new(record_opts)
    end
    records
  end
end
