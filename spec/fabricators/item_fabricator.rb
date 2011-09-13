Fabricator(ActivityFeed::Item) do
  user_id { sequence(:user_id) }
  nickname { sequence(:nickname) { |i| "nickname_#{i}" } }
  type { 'activity' }
  text { 'feed item' }
end
