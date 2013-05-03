# CHANGELOG

## 2.3.0 (2013-05-03)

* Added `check_item?(user_id, item_id, aggregate = ActivityFeed.aggregate)` to see if an item is in an activity feed.

## 2.2.2 (2012-09-12)

* Added `add_item(...)` as an alias for `update_item(...)`.

## 2.2.1 (2012-08-27)

* Added `total_pages` and `total_items` as aliases for `total_pages_in_feed` and `total_items_in_feed`, respectively.

## 2.2.0 (2012-08-20)

* Added `expire_feed(user_id, seconds, aggregate = ActivityFeed.aggregate)` and `expire_feed_at(user_id, timestamp, aggregate = ActivityFeed.aggregate)` methods to expire an activity feed after a given number of seconds or at a given time stamp, respectively.

## 2.1.0 (2012-08-13)

* Added `full_feed(user_id, aggregate = ActivityFeed.aggregate)` method to be able to retrieve an entire activity feed

## 2.0.0 (2012-06-29)

* Rewrite of the activity_feed gem
* Simplifies namespace in Redis
* Simplifies code to manipulate items and feeds
* Removes explicit ORM/ODM support and delegates that to `item_loader` if necessary
* Adds internal code documentation

## 1.4.0

* Added support for [Mongoid](http://www.mongoid.org)

## 1.3.0

* `ActivityFeed.update_item(user_id, item_id, timestamp, aggregate = false)` allows for updating an activity feed item in the personal or aggregate feed
* `ActivityFeed.delete_item(user_id, item_id, aggregate = false)` allows for removing an activity feed item from the personal or aggregate feed

## 1.2.2

* `ActivityFeed.create_item(attributes, aggregate)` can take an array of user_ids as its 2nd parameter if you want to fan out to the aggregation on create

## 1.2.1

* `ActivityFeed.feed(user_id)` will now return an instance of ActivityFeed::Feed
* `ActivityFeed::Ohm::Item` will now return all of its attributes when calling `to_json`

## 1.2

* Support aggregate feeds

## 1.1.1

* Removing activemodel dependency since that is not needed

## 1.1.0

* Added support for Ohm persistence, http://ohm.keyvalue.org
* Updated specs

## 1.0.0

* Initial release
