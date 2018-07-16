describe 'WaxTasks::PagemasterCollection' do
  include_context 'shared'
  include_context 'pagemaster'

  describe '.new' do
    context 'when given valid configuration info' do
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
        pages = quiet_stdout { valid_collection.generate_pages(write=false) }
        expect(pages).not_to be_empty
        expect(pages.first).to have_key('layout')
      end
    end
  end
end
