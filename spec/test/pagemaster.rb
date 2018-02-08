require 'rake'
require 'yaml'

describe 'wax:pagemaster' do
  it 'generates pages' do
    load File.expand_path("../../../lib/tasks/pagemaster.rake", __FILE__)
    Rake::Task['wax:pagemaster'].invoke
  end
end
