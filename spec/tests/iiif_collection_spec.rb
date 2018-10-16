describe WaxTasks::IiifCollection do
  include_context 'shared'

  before(:all) { WaxTasks::Test.reset }
  let(:iiif_collection) { WaxTasks::IiifCollection.new(args.first, default_site) }
  let(:no_variants_collection) do
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
      expect(iiif_collection.name).to eq(args.first)
    end

    context 'with custom variants' do
      it 'gets them as a Hash' do
        expect(iiif_collection.variants).to be_a(Hash)
      end
    end

    context 'without custom variants' do
      it 'uses WaxTasks::DEFAULT_IMAGE_VARIANTS' do
        expect(no_variants_collection.variants).to eq(WaxTasks::DEFAULT_IMAGE_VARIANTS)
      end
    end
  end

  describe '.records' do
    it 'returns an array of valid image records' do
      records = quiet_stdout { iiif_collection.records }
      expect(records).to be_an(Array)
      expect(records.first).to be_a(WaxIiif::ImageRecord)
    end
  end
end
