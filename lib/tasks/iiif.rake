require 'wax_tasks'
require 'iiif_s3'

namespace :wax do
  task :iiif => :config do
    abort "You must specify a collections after 'bundle exec rake wax:iiif'.".magenta if $argv.empty?
    FileUtils.mkdir_p './_iiif/tiles'
    all_records = []
    id_counter = 0
    build_opts = {
      :base_url => $config['baseurl'] + '/tiles',
      :output_dir => './_iiif/tiles',
      :tile_scale_factors => [1, 2],
      :verbose => true
    }
    $argv.each do |a|
      id_counter += 1
      dirpath = './_iiif/source_images/' + a
      collection_records = make_records(a) if Dir.exist?(dirpath)
      all_records.concat collection_records
      abort "Source path '#{dirpath}' does not exist. Exiting.".magenta unless Dir.exist?(dirpath)
    end
    builder = IiifS3::Builder.new(build_opts)
    builder.load(all_records)
    builder.process_data
  end
end

def make_records(collection_name)
  counter = 1
  collection_records = []
  imagefiles = Dir['./_iiif/source_images/' + collection_name + '/*'].sort!
  imagefiles.each do |imagefile|
    basename = File.basename(imagefile, '.*').to_s
    record_opts = {
      :id => collection_name + '-' + basename,
      :is_document => false,
      :path => imagefile,
      :label => $config['title'] + ' - ' + collection_name + ' - ' + basename
    }
    counter += 1
    collection_records << IiifS3::ImageRecord.new(record_opts)
  end
  collection_records
end
