describe WaxTasks::IiifCollection do
  include_context 'shared'

  before(:all) { WaxTasks::Test.reset }
  let(:iiif_collection) { WaxTasks::IiifCollection.new(args.first, default_site) }
  let(:pdf) { '_data/iiif/test_collection/2.pdf' }
  let(:pdf_image_dir) { '_data/iiif/test_collection/2' }
  describe '.new' do
    it 'initializes a collection' do
      expect(iiif_collection.name).to eq(args.first)
    end

    it 'gets the label key' do
      expect(iiif_collection.label).to eq('gambrel')
    end

    it 'gets the description key' do
      expect(iiif_collection.description).to eq('indescribable')
    end

    it 'gets the attribution key' do
      expect(iiif_collection.attribution).to eq('blasphemous')
    end

    it 'gets the logo path' do
      expect(iiif_collection.logo).to eq('/path/to/logo')
    end
  end

  describe '.split_pdf' do
    it 'splits the pdf' do
      images = quiet_stdout { iiif_collection.split_pdf(pdf) }
      expect(images.length).to eq(4)
      FileUtils.rm_r(pdf_image_dir)
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
