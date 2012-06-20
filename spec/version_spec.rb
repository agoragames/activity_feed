require 'spec_helper'

describe ActivityFeed do
  it "should be the correct version" do
    ActivityFeed::VERSION.should == '2.0.0'
  end
end