context '$ bundle exec rake' do
  include_context 'shared'

  before(:all) do
    WaxTasks::Test.reset
  end

  describe 'wax:pagemaster' do
    it 'runs without errors' do
      passes = quiet_stdout{ system("bundle exec rake wax:pagemaster #{args.first}") }
      expect(passes).to eq(true)
    end

    it 'generates pages' do
      pages = Dir.glob("_#{args.first}/*.md")
      expect(pages.length).not_to be_zero
    end
  end

  describe 'wax:lunr' do
    it 'runs without errors' do
      passes = quiet_stdout{ system("bundle exec rake wax:lunr") }
      expect(passes).to eq(true)
    end

    it 'generates an index' do
      expect(File).to exist(index_path)
      index = WaxTasks::Utils.remove_yaml(File.read(index_path))
      File.open(index_path, 'w') { |f| f.write(index) }
      expect { WaxTasks::Utils.validate_json(index_path) }.to_not raise_error
      expect(JSON.load(File.read(index_path))).not_to be_empty
    end

    context 'when run with UI=true' do
      it 'generates a ui' do
        quiet_stdout{ system("bundle exec rake wax:lunr UI=true") }
        expect(File).to exist(ui_path)
      end
    end
  end

  describe 'wax:derivatives:iiif' do
    it 'runs without errors' do
      passes = quiet_stdout { system("bundle exec rake wax:derivatives:iiif csv_collection") }
      expect(passes).to eq(true)
    end
  end

  describe 'wax:derivatives:simple' do
    it 'runs without errors' do
      passes = quiet_stdout { system("bundle exec rake wax:derivatives:simple json_collection") }
      expect(passes).to eq(true)
    end
  end
end
