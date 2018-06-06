require 'fileutils'
require 'jekyll'

require_relative 'data'

START_DIR     = Dir.pwd
BUILD_DIR     = "#{START_DIR}/build".freeze
IMAGE_SRC_DIR = "#{START_DIR}/spec/fake/iiif".freeze
DATA_DIR      = "#{BUILD_DIR}/_data".freeze

module Fake
  def self.site
    FileUtils.mkdir_p("#{DATA_DIR}/iiif")
    FileUtils.cd(BUILD_DIR)
    fake_config
    fake_gemfile
    fake_rakefile
    fake_index
    Bundler.with_clean_env { system('bundle --quiet') }
    Fake.data
    setup_iiif
  end

  def self.fake_config
    config = {
      'title' => 'site',
      'url' => '',
      'collections_dir' => 'collections',
      'baseurl' => '/test',
      'theme' => 'minima',
      'js' => {
        'jquery' => {
          'cdn' => 'test',
          'version' => 'test'
        }
      }
    }
    File.open('_config.yml', 'w') { |f| f.puts(config.to_yaml) }
  end

  def self.fake_gemfile
    File.open('Gemfile', 'w') do |f|
      f.puts("source 'https://rubygems.org'")
      f.puts("gem 'jekyll'")
      f.puts("gem 'minima'")
    end
  end

  def self.fake_rakefile
    File.open('Rakefile', 'w') do |f|
      f.puts('Dir.glob("../lib/wax/tasks/*.rake").each { |r| load r }')
    end
  end

  def self.fake_index
    File.open('index.html', 'w') do |f|
      f.puts('<html><head></head><body>Home</body></html>')
    end
  end

  def self.setup_iiif
    imgs = Dir.glob("#{IMAGE_SRC_DIR}/*.jpg")
    dirs = WaxTasks.site_config[:collections].map { |c| c[0] }
    dirs.each do |d|
      target_dir = "#{DATA_DIR}/iiif/#{d}"
      FileUtils.mkdir_p(target_dir)
      FileUtils.cp(imgs, target_dir)
    end
  end
end

def quiet_stdout
  if QUIET
    begin
      orig_stderr = $stderr.clone
      orig_stdout = $stdout.clone
      $stderr.reopen File.new('/dev/null', 'w')
      $stdout.reopen File.new('/dev/null', 'w')
      retval = yield
    rescue StandardError => e
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
      raise e
    ensure
      $stdout.reopen orig_stdout
      $stderr.reopen orig_stderr
    end
    retval
  else
    yield
  end
end
