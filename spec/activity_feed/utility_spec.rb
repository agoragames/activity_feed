require 'spec_helper'

describe ActivityFeed::Utility do
  describe '#feed_key' do
    it 'should return the correct key for the non-aggregate feed' do
      ActivityFeed.feed_key('david').should == 'activity_feed:david'
    end

    it 'should return the correct key for an aggregate feed' do
      ActivityFeed.feed_key('david', true).should == 'activity_feed:aggregate:david'
    end
  end

  describe '#feederboard_for' do
    it 'should create a leaderboard using an existing Redis connection' do
      feederboard_david = ActivityFeed.feederboard_for('david')
      feederboard_person = ActivityFeed.feederboard_for('person')

      feederboard_david.should_not be_nil
      feederboard_person.should_not be_nil
      ActivityFeed.redis.info["connected_clients"].to_i.should be(1)
    end
  end
end