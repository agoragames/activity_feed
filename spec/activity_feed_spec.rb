require 'spec_helper'

describe ActivityFeed do
  it 'should have defaults set for :namespace and :key' do
    ActivityFeed.namespace.should eql('activity')
    ActivityFeed.key.should eql('feed')    
  end
end