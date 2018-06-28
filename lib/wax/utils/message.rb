# Message stdout with color
module Message
  def self.share(msg)
    puts msg.cyan
  end

  def self.pagemaster_results(completed, dir)
    share("#{completed} pages were generated to #{dir} directory.")
  end

  def self.writing_index(path)
    share("Writing lunr index to #{path}")
  end

  def self.ui_exists(path)
    share("Lunr UI already exists at #{path}. Skipping.")
  end

  def self.writing_ui(path)
    share("Writing lunr ui to #{path}")
  end

  def self.writing_package_json(names)
    share("Writing #{names} to simple package.json.")
  end

  def self.skipping_package_json
    share('Cannot find js dependencies in config. Skipping package.json.')
  end
end
