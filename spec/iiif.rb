describe 'wax:iiif' do
  it 'constructs iiif collections' do
    expect { quiet_stdout { IIIF_COLLECTIONS.all? } }
  end
  context 'when invoked as a task' do
    it 'passes' do
      passes = quiet_stdout { system("bundle exec rake wax:iiif #{ARGS.first}") }
      expect(passes).to eq(true)
    end
    it 'generates collection json' do
      expect(File.exist?("./iiif/#{ARGS.first}/collection/top.json")).to be true
    end
    it 'generates manifest json' do
      expect(File.exist?("./iiif/#{ARGS.first}/0/manifest.json")).to be true
    end
    it 'adds manifest metadata fields from config + source' do
      manifest = JSON.parse(File.read("./iiif/#{ARGS.first}/0/manifest.json"))
      %w[label description].each do |k|
        expect(manifest).to have_key(k)
        expect(manifest[k]).not_to be_empty
      end
    end
    it 'generates derivatives' do
      expect(Dir.exist?("./iiif/#{ARGS.first}/images")).to be true
    end
    it 'generates custom image variants' do
      [100, 900].each do |size|
        expect(File.exist?("./iiif/#{ARGS.first}/images/1-1/full/#{size},/0/default.jpg")).to be true
      end
    end
  end
  context 'when processed directly' do
    it 'still passes' do
      expect { quiet_stdout { IIIF_COLLECTIONS.last.process } }.not_to raise_error
    end
  end
  context 'when looking for a missing dir' do
    it 'throws a configuration error' do
      expect { quiet_stdout { IiifCollection.new('not_a_collection') } }.to raise_error(SystemExit)
    end
  end
end
