# shared contexts
shared_context 'shared', :shared_context => :metadata do
  quiet_stdout {
    # valid
    let(:site_config) { WaxTasks::SITE_CONFIG }
    let(:args) { site_config[:collections].map { |c| c[0] } }
    let(:page_dir) {
      [
        site_config.fetch(:source_dir, nil),
        site_config.fetch(:collections_dir,nil),
        args.first
      ].compact.join('/')
    }
    let(:iiif_image_dir) {
      [
        site_config.fetch(:source_dir, nil),
        'iiif',
        args.last,
        'images'
      ].compact.join('/')
    }
    let(:index) {
      [
        site_config.fetch(:source_dir, nil),
        'js',
        'lunr-index.json'
      ].compact.join('/')
    }
    let(:ui) {
      [
        site_config.fetch(:source_dir, nil),
        'js',
        'lunr-ui.js'
      ].compact.join('/')
    }
  }
end

shared_context 'pagemaster', :shared_context => :metadata do

  let(:collections) { args.map { |a| WaxTasks::PagemasterCollection.new(a) } }
  let(:invalid_collection) do
    opts = { site_config: { 'collections' =>  nil } }
    WaxTasks::PagemasterCollection.new(args.first, opts)
  end
  let(:missing_src) do
    opts = {
      site_config: {
        collections: {
          args.first => {
            'source' => 'not-a-file.xls'
          }
        }
      }
    }
    WaxTasks::PagemasterCollection.new(args.first, opts)
  end
end

shared_context 'utils', :shared_context => :metadata do
  let(:valid_data) { WaxTasks::PagemasterCollection.new(args.first).data }
  let(:missing_pid_data) do
    data = WaxTasks::PagemasterCollection.new(args.first).data
    data.first.delete('pid')
    data
  end

  let(:nonunique_data) do
    data = WaxTasks::PagemasterCollection.new(args.first).data
    data[3] = data.first.dup
    data
  end
end
