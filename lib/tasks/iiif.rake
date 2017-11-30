namespace :wax do
  task :iiif => :config do
    begin
      require 'iiif_s3'
    rescue LoadError
      puts "This task requires the iiif_s3 gem. Please add to your Gemfile and re-run."
      next
    end

    FileUtils::mkdir_p 'tiles'
    imagedata = []
    id_counter = 0

    @argv.each do |a|
      @dirpath = './_iiif/' + a
      unless Dir.exist?(@dirpath)
        raise "wax:iiif :: " + @dirpath + " directory does not exist. Exiting."
      else
        id_counter = id_counter + 1
        imagefiles = Dir[@dirpath + "/*"].sort!
        counter = 1
        imagefiles.each do |imagefile|
          basename = File.basename(imagefile, ".*")
          opts = {}

          opts[:id] = basename
          opts[:is_document] = false
          opts[:path] = imagefile
          opts[:label] = @config["title"] + " - " + a + " - " + basename

          i = IiifS3::ImageRecord.new(opts)
          counter = counter + 1
          imagedata.push(i)
        end
      end
    end
    builder = IiifS3::Builder.new({
      :base_url => @config["baseurl"] + "/tiles",
      :output_dir => "./tiles",
      :tile_scale_factors => [1,2],
      :verbose => true
    })
    builder.load(imagedata)
    builder.process_data()
  end
end
