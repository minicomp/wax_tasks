shared_context 'shared', :shared_context => :metadata do
  let(:task_runner) { WaxTasks::TaskRunner.new }
  let(:new_title) { WaxTasks::TaskRunner.new.override(title: 'new title') }
  let(:new_perma) { WaxTasks::TaskRunner.new.override(permalink: 'pretty') }
  let(:new_collections) do
    WaxTasks::TaskRunner.new.override(collections: { 'test_collection' => 'test' })
  end
  let(:args) { task_runner.site[:collections].map { |c| c[0] } }
  let(:page_dirs) {
    args.map do |a|
      WaxTasks::Utils.make_path(task_runner.site[:source_dir], task_runner.site[:collections_dir],a)
    end
  }
  let(:index_path) do
    WaxTasks::Utils.make_path(task_runner.site[:source_dir],
                              WaxTasks::LUNR_INDEX_PATH)
  end
  let(:ui_path) do
    WaxTasks::Utils.make_path(task_runner.site[:source_dir],
                              WaxTasks::LUNR_UI_PATH)
  end
end

shared_context 'pagemaster', :shared_context => :metadata do
  let (:valid_collection) do
    WaxTasks::PagemasterCollection.new(args.first, task_runner.site)
  end
end

shared_context 'lunr', :shared_context => :metadata do

end

shared_context 'iiif', :shared_context => :metadata do

end

shared_context 'utils', :shared_context => :metadata do
  let(:valid_data) do
    WaxTasks::PagemasterCollection.new(args.first, task_runner.site).data
  end
  let(:missing_pid_data) do
    data = WaxTasks::PagemasterCollection.new(args.first, task_runner.site).data
    data.first.delete('pid')
    data
  end

  let(:nonunique_data) do
    data = WaxTasks::PagemasterCollection.new(args.first, task_runner.site).data
    data[3] = data.first.dup
    data
  end
end

# shared contexts
# shared_context 'shared', :shared_context => :metadata do
#   quiet_stdout {
#     # valid
#     let(:site_config) { WaxTasks::SITE_CONFIG }
#     let(:args) { site_config[:collections].map { |c| c[0] } }
#     let(:page_dir) {
#       [
#         site_config.fetch(:source_dir, nil),
#         site_config.fetch(:collections_dir,nil),
#         args.first
#       ].compact.join('/')
#     }
#     let(:iiif_image_dir) {
#       [
#         site_config.fetch(:source_dir, nil),
#         'iiif',
#         args.last,
#         'images'
#       ].compact.join('/')
#     }
#     let(:index) {
#       [
#         site_config.fetch(:source_dir, nil),
#         'js',
#         'lunr-index.json'
#       ].compact.join('/')
#     }
#     let(:ui) {
#       [
#         site_config.fetch(:source_dir, nil),
#         'js',
#         'lunr-ui.js'
#       ].compact.join('/')
#     }
#   }
# end

# shared_context 'pagemaster', :shared_context => :metadata do
#
#   let(:collections) { args.map { |a| WaxTasks::PagemasterCollection.new(a) } }
#   let(:invalid_collection) do
#     opts = { site_config: { 'collections' =>  nil } }
#     WaxTasks::PagemasterCollection.new(args.first, opts)
#   end
#   let(:missing_src) do
#     opts = {
#       site_config: {
#         collections: {
#           args.first => {
#             'source' => 'not-a-file.xls'
#           }
#         }
#       }
#     }
#     WaxTasks::PagemasterCollection.new(args.first, opts)
#   end
# end
#
