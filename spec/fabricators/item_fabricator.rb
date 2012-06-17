Fabricator(ActivityFeed::ActiveRecord::Item.to_s) do
  user_id { sequence(:user_id) }
  nickname { sequence(:nickname) { |i| "nickname_#{i}" } }
  type { 'activity' }
  title { 'item title' }
  text { 'feed item' }
  url { 'http://url' }
  icon { 'http://icon' }
  sticky { false }
end

Fabricator(ActivityFeed::Memory::Item.to_s) do
  user_id { sequence(:user_id) }
  nickname { sequence(:nickname) { |i| "nickname_#{i}" } }
  type { 'activity' }
  title { 'item title' }
  text { 'feed item' }
  url { 'http://url' }
  icon { 'http://icon' }
  sticky { false }
end

Fabricator(ActivityFeed::MongoMapper::Item.to_s) do
  user_id { sequence(:user_id) }
  nickname { sequence(:nickname) { |i| "nickname_#{i}" } }
  type { 'activity' }
  title { 'item title' }
  text { 'feed item' }
  url { 'http://url' }
  icon { 'http://icon' }
  sticky { false }
end

Fabricator(ActivityFeed::Mongoid::Item.to_s) do
  user_id { sequence(:user_id) }
  nickname { sequence(:nickname) { |i| "nickname_#{i}" } }
  type { 'activity' }
  title { 'item title' }
  text { 'feed item' }
  url { 'http://url' }
  icon { 'http://icon' }
  sticky { false }
end

Fabricator(ActivityFeed::Ohm::Item.to_s) do
  user_id { sequence(:user_id) }
  nickname { sequence(:nickname) { |i| "nickname_#{i}" } }
  type { 'activity' }
  title { 'item title' }
  text { 'feed item' }
  url { 'http://url' }
  icon { 'http://icon' }
  sticky { false }
end
