Fabricator(ActivityFeed::Item) do
  user_id { sequence(:user_id) }
  nickname { sequence(:nickname) { |i| "nickname_#{i}" } }
  type { 'activity' }
  title { 'item title' }
  text { 'feed item' }
  url { 'http://url' }
  icon { 'http://icon' }
  sticky { false }
end
