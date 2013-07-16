require 'spec_helper'

describe 'ActivityFeed::VERSION' do
  it 'should be the correct version' do
    ActivityFeed::VERSION.should == '3.0.1'
  end
end