describe WaxTasks::IiifCollection do
  include_context 'shared'

  before(:all) { WaxTasks::Test.reset }
  let(:images_collection) { WaxTasks::IiifCollection.new('imgc', default_site) }
  let(:pdf_collection) { WaxTasks::IiifCollection.new('pdfc', default_site) }
  let(:document_collection) { WaxTasks::IiifCollection.new('docc', default_site) }
  let(:no_variants) do
    opts = {
      collections: {
        args.first => { 'source' => 'valid.csv', 'iiif' => { 'meta' => [{ 'label' => 'gambrel' }] } }
      }
    }
    runner = WaxTasks::TaskRunner.new.override(opts)
    WaxTasks::IiifCollection.new(args.first, runner.site)
  end

  describe '.new' do
    it 'initializes a collection' do
      expect(images_collection.name).to eq(args.first)
    end

    context 'with custom variants' do
      it 'gets them as a Hash' do
        expect(images_collection.variants).to be_a(Hash)
      end
    end

    context 'without custom variants' do
      it 'uses WaxTasks::DEFAULT_IMAGE_VARIANTS' do
        expect(no_variants.variants).to eq(WaxTasks::DEFAULT_IMAGE_VARIANTS)
      end
    end
  end

  describe '.pdf' do
    context 'when a pdf IIIF source is available' do
      it 'returns true' do
        expect(pdf_collection.pdf?).to be(true)
      end
    end
    context 'when a pdf IIIF source isn\'t found' do
      it 'returns false' do
        expect(images_collection.pdf?).to be(false)
      end
    end
  end

  describe '.document' do
    context 'when \'is_document: true\' is in collection config' do
      it 'returns true' do
        expect(document_collection.document?).to be(true)
      end
    end

    context 'when \'is_document\' key is absent in collection config' do
      it 'returns false' do
        expect(images_collection.document?).to be(false)
      end
    end

    context 'when a pdf IIIF source is available' do
      it 'returns true by default' do
        expect(pdf_collection.document?).to be(true)
      end
    end
  end

  describe '.records' do
    context 'with a collection of single images' do
      it 'returns an array of valid image records' do
        records = quiet_stdout { images_collection.records }
        expect(records).to be_an(Array)
        expect(records.first).to be_a(WaxIiif::ImageRecord)
      end
    end

    context 'with a collection of images representing a document' do
      it 'returns an array of valid image records' do
        records = quiet_stdout { document_collection.records }
        expect(records).to be_an(Array)
        expect(records.first).to be_a(WaxIiif::ImageRecord)
      end
    end

    context 'with a pdf document' do
      it 'returns an array of valid image records' do
        records = quiet_stdout { pdf_collection.records }
        expect(records).to be_an(Array)
        expect(records.first).to be_a(WaxIiif::ImageRecord)
      end
    end
  end
end
