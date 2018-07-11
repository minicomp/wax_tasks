describe 'WaxTasks::PagemasterCollection' do
  include_context 'shared'
  include_context 'pagemaster'

  describe '.new' do
    it 'initializes a valid collection' do
      expect(collections.all?)
    end
    it 'accesses collection data' do
      expect(collections.first.data.length)
    end
    context 'when given a collection not it config' do
      it 'throws WaxTasks::Error::InvalidCollection' do
        expect { quiet_stdout { invalid_collection } }.to raise_error(WaxTasks::Error::InvalidCollection)
      end
    end
    context 'when given a src file that doesn\'t exist' do
      it 'throws WaxTasks::Error::MissingSource' do
        expect { quiet_stdout { missing_src } }.to raise_error(WaxTasks::Error::MissingSource)
      end
    end
  end

  describe '.generate_pages' do
    it 'runs without errors' do
      expect { quiet_stdout { collections.first.generate_pages } }.not_to raise_error
    end

    it 'skips existing pages' do
      expect { collections.first.generate_pages }.to output(/.*Skipping.*/).to_stdout
    end

    context 'when @ordered' do
      it 'adds an order var to each page' do
        collections.last.ordered = true
        quiet_stdout { collections.last.generate_pages }
        page = Dir.glob("#{collections.last.page_dir}/*.md").first
        expect(YAML.load_file(page)).to have_key('order')
      end
    end
  end
end
