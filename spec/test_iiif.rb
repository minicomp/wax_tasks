require 'csv'
require 'fileutils'
require 'rake'

include FileUtils

describe 'wax:iiif' do
  it 'generates iiif tiles and data' do
    images = Dir.glob('_iiif/*.jpg')
    $collection_data.each do |coll|
      new_dir = '_iiif/' + coll[0]
      mkdir_p(new_dir)
      images.each { |f| cp(File.expand_path(f), new_dir) }
    end
    rm_r(images)
    $argv = [$argv.first] # make tests faster by only running on 1/3 collections
    load File.expand_path("../../lib/tasks/iiif.rake", __FILE__)
    Rake::Task['wax:iiif'].invoke
  end
end
