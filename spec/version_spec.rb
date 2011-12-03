require 'spec_helper'

describe ActivityFeed do
  it "should be the correct version" do
    ActivityFeed::VERSION.should == '1.2.1'
  end
end