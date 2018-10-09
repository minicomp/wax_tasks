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

  describe 'test' do
    it 'tests' do
      task_runner.iiif(args)
    end
  end

  # describe '.new' do
  #   context 'when given valid configuration info' do
  #     it 'initializes a collection' do
  #       expect(images_collection.name).to eq(args.first)
  #     end
  #
  #     it 'gets the variants' do
  #       expect(images_collection.variants).to be_a(Hash)
  #     end
  #
  #     context 'without custom variants' do
  #       it 'builds without errors' do
  #         expect(no_variants.variants).to eq({:med=>600, :lg=>1140})
  #       end
  #     end
  #   end
  # end
  #
  # describe '.process' do
  #   context 'with a collection of single images' do
  #     it 'runs without errors' do
  #       expect{ quiet_stdout { images_collection.process } }.not_to raise_error
  #     end
  #
  #     it 'generates collection json' do
  #       expect(File.exist?("#{BUILD}/#{images_collection.target_dir}/collection/top.json")).to be true
  #     end
  #
  #     it 'generates manifest json' do
  #       expect(File.exist?("#{BUILD}/#{images_collection.target_dir}/0/manifest.json")).to be true
  #     end
  #
  #     it 'generates derivatives' do
  #       expect(Dir.exist?("#{BUILD}/#{images_collection.target_dir}/images")).to be true
  #     end
  #
  #     it 'generates custom image variants' do
  #       [100, 900].each do |size|
  #         expect(File.exist?("#{BUILD}/#{images_collection.target_dir}/images/1-1/full/#{size},/0/default.jpg")).to be true
  #       end
  #     end
  #   end
  #
  #   context 'with a collection of images representing a document' do
  #     it 'runs without errors' do
  #       expect{ quiet_stdout { document_collection.process } }.not_to raise_error
  #     end
  #
  #     it 'generates collection json' do
  #       expect(File.exist?("#{BUILD}/#{document_collection.target_dir}/collection/top.json")).to be true
  #     end
  #
  #     it 'generates manifest json' do
  #       expect(File.exist?("#{BUILD}/#{document_collection.target_dir}/0/manifest.json")).to be true
  #     end
  #
  #     it 'generates derivatives' do
  #       expect(Dir.exist?("#{BUILD}/#{document_collection.target_dir}/images")).to be true
  #     end
  #
  #     it 'generates custom image variants' do
  #       [100, 900].each do |size|
  #         expect(File.exist?("#{BUILD}/#{document_collection.target_dir}/images/1-1/full/#{size},/0/default.jpg")).to be true
  #       end
  #     end
  #   end
  #
  #   context 'with a pdf document' do
  #     it 'runs without errors' do
  #       expect{ quiet_stdout { pdf_collection.process } }.not_to raise_error
  #     end
  #
  #     it 'generates collection json' do
  #       expect(File.exist?("#{BUILD}/#{pdf_collection.target_dir}/collection/top.json")).to be true
  #     end
  #
  #     it 'adds manifest metadata fields from config + source' do
  #       manifest = JSON.parse(File.read("#{BUILD}/#{pdf_collection.target_dir}/0/manifest.json"))
  #       expect(manifest).to have_key('label')
  #     end
  #
  #     it 'generates derivatives' do
  #       expect(Dir.exist?("#{BUILD}/#{pdf_collection.target_dir}/images")).to be true
  #     end
  #   end
  # end
end
