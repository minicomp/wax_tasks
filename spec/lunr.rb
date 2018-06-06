# lunr task specs
describe 'wax:lunr' do
  it 'constructs an index object' do
    idx = quiet_stdout { Index.new }
    expect { idx.collections.all? }
  end
  it 'passes when invoked' do
    passes = quiet_stdout { system('bundle exec rake wax:lunr') }
    expect(passes).to eq(true)
  end
  it 'writes a lunr index' do
    index = File.open('./js/lunr-index.json', 'r').read
    expect(index.length).to be > 1000
  end
  it 'generates a lunr ui' do
    ui = File.open('./js/lunr-ui.js', 'r').read
    expect(ui.length).to be > 100
  end
  context 'when a ui already exists' do
    it 'skips over it' do
      expect { Index.new.write }.to output(/.*Skipping.*/).to_stdout
    end
  end
end
