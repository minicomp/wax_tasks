# frozen_string_literal: true

describe WaxTasks::Site do
  include_context 'shared'

  before(:all) do
    Test.reset
  end
  subject(:site_from_default) { WaxTasks::Site.new }
  it { should be_a(WaxTasks::Site) }
end
