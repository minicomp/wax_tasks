context '$ bundle exec rake' do
  include_context 'shared'

  before(:all) do
    WaxTasks::Test.reset
  end

  describe 'wax:pagemaster' do
    it 'runs without errors' do
      passes = quiet_stdout{ system("bundle exec rake wax:pagemaster #{args.join(' ')}") }
      expect(passes).to eq(true)
    end

    it 'generates pages' do
      pages = Dir.glob('my_collection/*.md')
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
      index = File.read(index_path).remove_yaml
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

  describe 'wax:iiif' do
    it 'runs without errors' do
      passes = quiet_stdout { system("bundle exec rake wax:iiif #{args.last}") }
      expect(passes).to eq(true)
    end

    it 'builds iiif info.json' do
      iiif_collection = WaxTasks::IiifCollection.new(args.last, task_runner.site)
      first_image = Dir.glob("#{iiif_collection.target_dir}/images/*").first
      expect(File).to exist("#{first_image}/info.json")
    end
  end

  describe 'wax:jspackage' do
    it 'passes' do
      passes = quiet_stdout { system('bundle exec rake wax:jspackage') }
      expect(passes).to eq(true)
    end
    it 'writes a package.json file' do
      package = File.open('package.json', 'r').read
      expect(package.length > 90)
    end
  end
end
