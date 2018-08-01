describe WaxTasks::PagemasterCollection do
  include_context 'shared'

  before(:all) { WaxTasks::Test.reset }
  let(:valid_collection) { WaxTasks::PagemasterCollection.new(args.first, default_site) }
  let(:valid_yaml) do
    opts    = { collections: { args.first => { 'layout' => 'default.html', 'source' => 'valid.yml'} } }
    runner  = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::PagemasterCollection.new(args.first, runner.site)
  end
  let(:invalid_yaml) do
    opts    = { collections: { args.first => { 'layout' => 'default.html', 'source' => '.invalid.yml'} } }
    runner  = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::PagemasterCollection.new(args.first, runner.site)
  end
  let(:valid_json) do
    opts    = { collections: { args.first => { 'layout' => 'default.html', 'source' => 'valid.json'} } }
    runner  = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::PagemasterCollection.new(args.first, runner.site)
  end
  let(:invalid_json) do
    opts    = { collections: { args.first => { 'layout' => 'default.html', 'source' => '.invalid.json'} } }
    runner  = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::PagemasterCollection.new(args.first, runner.site)
  end
  let(:invalid_type) do
    opts    = { collections: { args.first => { 'layout' => 'default.html', 'source' => '.invalid.xls'} } }
    runner  = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::PagemasterCollection.new(args.first, runner.site)
  end

  describe '.new' do
    context 'when given valid csv configuration info' do
      it 'initializes a collection' do
        expect(valid_collection.name).to eq(args.first)
      end

      it 'gets the layout' do
        expect(valid_collection.layout).to be_a(String)
      end

      it 'gets the source path' do
        expect(valid_collection.source).to be_a(String)
      end

      it 'keeps the results ordered' do
        expect(valid_collection.ordered).to eq(true).or eq(false)
      end

      it 'ingests the data source file' do
        expect(valid_collection.data.first).to have_key('pid')
      end

      it 'generates pages' do
        pages = quiet_stdout { valid_collection.generate_pages }
        expect(pages).not_to be_empty
        expect(pages.first).to have_key('layout')
      end
    end

    context 'when overriding the source with valid yaml' do
      it 'initializes the collection' do
        expect(valid_yaml.name).to eq(args.first)
      end

      it 'generates the pages' do
        expect(quiet_stdout { valid_yaml.generate_pages.first }).to have_key('pid')
      end
    end

    context 'when overriding the source with invalid yaml' do
      it 'throws WaxTasks::Error::InvalidYAML' do
        expect{ invalid_yaml }.to raise_error(WaxTasks::Error::InvalidYAML)
      end
    end

    context 'when overriding the source with valid json' do
      it 'initializes the collection' do
        expect(valid_json.name).to eq(args.first)
      end

      it 'generates the pages' do
        expect(quiet_stdout { valid_json.generate_pages.first }).to have_key('pid')
      end
    end

    context 'when overriding the source with invalid json' do
      it 'throws WaxTasks::Error::InvalidJSON)' do
        expect{ invalid_json }.to raise_error(WaxTasks::Error::InvalidJSON)
      end
    end

    context 'when given an invalid data type, e.g. .xls' do
      it 'throws WaxTasks::Error::InvalidSource' do
        expect{ invalid_type }.to raise_error(WaxTasks::Error::InvalidSource)
      end
    end
  end
end
