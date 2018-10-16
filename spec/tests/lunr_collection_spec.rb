describe WaxTasks::LunrCollection do
  include_context 'shared'

  before(:all) { WaxTasks::Test.reset }

  let(:valid_collection) { WaxTasks::LunrCollection.new(args.first, default_site) }
  let(:invalid_collection) { WaxTasks::LunrCollection.new('not_a_collection', default_site) }
  let(:missing_fields_collection) do
    no_fields = { collections: { 'missing_fields_collection' => { 'lunr_index' => {} } } }
    runner = WaxTasks::TaskRunner.new.override(no_fields)
    WaxTasks::LunrCollection.new('missing_fields_collection', runner.site)
  end

  describe '.new' do
    context 'when given valid configuration info' do
      it 'initializes a collection' do
        quiet_stdout { task_runner.pagemaster([args.first]) }
        expect(valid_collection.fields).to be_an(Array)
        expect(valid_collection.fields).not_to be_empty
      end
    end

    context 'when given a collection that doesn\'t exist' do
      it 'throws WaxTasks::Error::InvalidCollection' do
        expect{ quiet_stdout { invalid_collection } }.to raise_error(WaxTasks::Error::InvalidCollection)
      end
    end

    context 'when given a collection without fields to index' do
      it 'throws WaxTasks::Error::MissingFields' do
        expect{ quiet_stdout { missing_fields_collection  } }.to raise_error(WaxTasks::Error::MissingFields)
      end
    end
  end

  describe '.ingest_pages' do
    context 'when given a directory of markdown pages' do
      it 'loads them as a hash array' do
        expect(valid_collection.ingest_pages).to be_an(Array)
        expect(valid_collection.ingest_pages.first).to have_key('pid')
      end
    end

    context 'when the directory of pages to index is empty or doesn\'t exist' do
      it 'puts "There are no pages to index" to stdout' do
        WaxTasks::Test.reset
        expect { valid_collection.ingest_pages }.to output(/There are no pages/).to_stdout
      end
    end
  end
end
