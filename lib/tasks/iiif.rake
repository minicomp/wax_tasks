require 'wax_tasks'
require 'iiif_s3'

namespace :wax do
  task :iiif => :config do
    abort "You must specify a collections after 'bundle exec rake wax:iiif'.".magenta if $argv.empty?
    outputdir = './iiif'
    FileUtils.mkdir outputdir
    all_records = []
    id_counter = 0
    build_opts = {
      :base_url => $config['baseurl'] + '/iiif',
      :output_dir => outputdir,
      :tile_scale_factors => [1, 2],
      :verbose => true
    }
    $argv.each do |a|
      id_counter += 1
      inpath = './_data/iiif/' + a
      abort "Source path '#{inpath}' does not exist. Exiting.".magenta unless Dir.exist?(inpath)
      paged = $config['collections'][a]['iiif_paged'] == true
      collection_records = make_records(a, inpath, paged)
      all_records.concat collection_records
    end
    builder = IiifS3::Builder.new(build_opts)
    builder.load(all_records)
    builder.process_data
  end
end

def make_records(collection_name, inpath, paged)
  counter = 1
  collection_records = []
  imagefiles = Dir[inpath + '/*'].sort!
  imagefiles.each do |imagefile|
    basename = File.basename(imagefile, '.*').to_s
    record_opts = {
      :id => collection_name + '-' + basename,
      :is_document => paged,
      :path => imagefile,
      :label => $config['title'] + ' - ' + collection_name + ' - ' + basename
    }
    counter += 1
    collection_records << IiifS3::ImageRecord.new(record_opts)
  end
  collection_records
end
