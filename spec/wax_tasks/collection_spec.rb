# frozen_string_literal: true

describe WaxTasks::Collection do
  include_context 'shared'
  let(:config)          { site_from_config_file.config }
  let(:source)          { config.source }
  let(:collections_dir) { config.collections_dir }
  let(:ext)             { config.ext }
  let(:csv_collection)  { config.find_collection csv }
  let(:json_collection) { config.find_collection json }
  let(:yaml_collection) { config.find_collection yaml }

  before(:all) do
    Test.reset
  end

  describe '#new' do
    it 'test' do
      puts csv_collection
    end
  end
end
