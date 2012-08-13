require 'spec_helper'

describe 'ActivityFeed::VERSION' do
  it "should be the correct version" do
    ActivityFeed::VERSION.should == '2.1.0'
  end
end