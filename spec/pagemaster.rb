# pagemaster task specs
describe 'wax:pagemaster' do
  it 'constructs pagemaster collections' do
    expect { PM_COLLECTIONS.all? }
  end
  context 'when invoked as a task' do
    it 'passes' do
      passes = quiet_stdout { system("bundle exec rake wax:pagemaster #{ARGS.join ' '}") }
      expect(passes).to eq(true)
    end
    it 'generates pages to the correct directories' do
      PM_COLLECTIONS.each do |c|
        pages = Dir.glob("#{c.page_dir}/*.md")
        expect(pages.length).to be > 0
        Fake.content(pages) # add content to pages to test lunr indexing
      end
    end
  end
  context 'when processed directly' do
    it 'still passes' do
      FileUtils.rm_r "./collections/_#{ARGS.first}"
      expect { quiet_stdout { PM_COLLECTIONS.first.generate_pages } }.not_to raise_error
    end
  end
  context 'when given a collection arg not in config' do
    it 'throws a configuration error' do
      expect { quiet_stdout { PagemasterCollection.new('not_a_collection') } }.to raise_error(SystemExit)
    end
  end
  context 'when trying to genrate pages that already exist' do
    it 'skips them' do
      expect { PM_COLLECTIONS.first.generate_pages }.to output(/.*Skipping.*/).to_stdout
    end
  end
  context 'when given a bad config' do
    it 'throws a key error' do
      opts = { site_config: {} }
      expect { PagemasterCollection.new(ARGS.first, opts) }.to raise_error(KeyError)
    end
  end
end
