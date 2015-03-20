require 'spec_helper'

describe ActivityFeed::Utility do
  describe '#feed_key' do
    it 'should return the correct key for the non-aggregate feed' do
      expect(ActivityFeed.feed_key('david')).to eq('activity_feed:david')
    end

    it 'should return the correct key for an aggregate feed' do
      expect(ActivityFeed.feed_key('david', true)).to eq('activity_feed:aggregate:david')
    end
  end

  describe '#feederboard_for' do
    it 'should create a leaderboard using an existing Redis connection' do
      feederboard_david = ActivityFeed.feederboard_for('david')
      feederboard_person = ActivityFeed.feederboard_for('person')

      expect(feederboard_david).not_to be_nil
      expect(feederboard_person).not_to be_nil
    end
  end
end