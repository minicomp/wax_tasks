require 'colorized_string'
require 'iiif_s3'

namespace :wax do
  task :iiif => :config do
    FileUtils.mkdir_p 'tiles'
    imagedata = []
    id_counter = 0
    if $argv.empty?
      puts("You must specify one or more collections after 'bundle exec rake wax:iiif' to generate.").magenta
      exit 1
    else
      build_opts = {
        :base_url => $config['baseurl'] + '/tiles',
        :output_dir => './tiles',
        :tile_scale_factors => [1, 2],
        :verbose => true
      }
      $argv.each do |a|
        dirpath = './_iiif/' + a
        if Dir.exist?(dirpath)
          id_counter += 1
          imagefiles = Dir[dirpath + '/*'].sort!
          counter = 1
          imagefiles.each do |imagefile|
            begin
              basename = File.basename(imagefile, '.*').to_s
              record_opts = {
                :id => a + '-' + basename,
                :is_document => false,
                :path => imagefile,
                :label => $config['title'] + ' - ' + a + ' - ' + basename
              }
              i = IiifS3::ImageRecord.new(record_opts)
              counter += 1
              imagedata.push(i)
            rescue StandardError
              puts('Failed to convert image ' + imagefile + '.').magenta
              exit 1
            end
          end
        else
          puts("Source path '" + dirpath + "' does not exist. Exiting.").magenta
          exit 1
        end
      end
      builder = IiifS3::Builder.new(build_opts)
      builder.load(imagedata)
      builder.process_data()
    end
  end
end
