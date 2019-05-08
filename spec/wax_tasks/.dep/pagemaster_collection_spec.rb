describe WaxTasks::PagemasterCollection do
  include_context 'shared'

  before(:all) { WaxTasks::Test.reset }
  let(:csv_collection) { WaxTasks::PagemasterCollection.new('csv_collection', default_site) }
  let(:yaml_collection) { WaxTasks::PagemasterCollection.new('yaml_collection', default_site) }
  let(:json_collection) { WaxTasks::PagemasterCollection.new('json_collection', default_site) }
  let(:invalid_yaml) do
    opts    = { collections: { args.first => { 'layout' => 'default.html', 'metadata' => { 'source' => 'invalid/.invalid.yml' } } } }
    runner  = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::PagemasterCollection.new(args.first, runner.site)
  end
  let(:invalid_json) do
    opts    = { collections: { args.first => { 'layout' => 'default.html', 'metadata' => { 'source' => 'invalid/.invalid.json' } } } }
    runner  = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::PagemasterCollection.new(args.first, runner.site)
  end
  let(:invalid_type) do
    opts    = { collections: { args.first => { 'layout' => 'default.html', 'metadata' => { 'source' => 'invalid/.invalid.xls' } } } }
    runner  = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::PagemasterCollection.new(args.first, runner.site)
  end

  describe '.new' do
    context 'when given valid csv configuration' do
      it 'initializes a collection' do
        expect(csv_collection.name).to eq('csv_collection')
      end

      it 'gets the layout' do
        expect(csv_collection.layout).to be_a(String)
      end

      it 'gets the source path' do
        expect(csv_collection.metadata_source_path).to be_a(String)
      end

      it 'ingests the data source file' do
        expect(csv_collection.metadata.first).to have_key('pid')
      end

      it 'generates pages' do
        pages = quiet_stdout { csv_collection.generate_pages }
        expect(pages).not_to be_empty
        expect(pages.first).to have_key('layout')
      end
    end

    context 'when given valid json configuration' do
      it 'initializes the collection' do
        expect(json_collection.name).to eq('json_collection')
      end

      it 'generates the pages' do
        expect(quiet_stdout { json_collection.generate_pages.first }).to have_key('pid')
      end
    end

    context 'when given valid yaml configuration' do
      it 'initializes the collection' do
        expect(yaml_collection.name).to eq('yaml_collection')
      end

      it 'generates the pages' do
        expect(quiet_stdout { yaml_collection.generate_pages.first }).to have_key('pid')
      end
    end

    context 'when given invalid yaml configuration' do
      it 'throws WaxTasks::Error::InvalidYAML' do
        expect{ invalid_yaml }.to raise_error(WaxTasks::Error::InvalidYAML)
      end
    end


    context 'when given invalid json configuration' do
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
