require 'colorized_string'
require 'iiif_s3'

namespace :wax do
  task :iiif => :config do

    FileUtils::mkdir_p 'tiles'
    imagedata = []
    id_counter = 0

    if $argv.empty?
      raise "You must specify one or more collections after 'bundle exec rake wax:iiif' to generate.".magenta
    else
      $argv.each do |a|
        dirpath = './_iiif/' + a
        unless Dir.exist?(dirpath)
          raise ("Source path '" + dirpath + "' does not exist. Exiting.").magenta
        else
          id_counter+=1
          imagefiles = Dir[dirpath + "/*"].sort!
          counter = 1
          imagefiles.each do |imagefile|
            begin
              basename = File.basename(imagefile, ".*")
              opts = {}
              opts[:id] = basename
              opts[:is_document] = false
              opts[:path] = imagefile
              opts[:label] = $config["title"] + " - " + a + " - " + basename
              i = IiifS3::ImageRecord.new(opts)
              counter = counter + 1
              imagedata.push(i)
            rescue
              raise ("Failed to convert image " + imagefile + ".").magenta
            end
          end
        end
      end
      builder = IiifS3::Builder.new({
        :base_url => $config["baseurl"] + "/tiles",
        :output_dir => "./tiles",
        :tile_scale_factors => [1,2],
        :verbose => true
      })
      builder.load(imagedata)
      builder.process_data()
    end
  end
end
