Fabricator(ActivityFeed::Item) do
  mlg_id { sequence(:mlg_id) }
  nickname { sequence(:nickname) { |i| "nickname_#{i}" } }
  type { 'activity' }
  text { 'feed item' }
end
