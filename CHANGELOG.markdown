# CHANGELOG

## 1.2.1

* ActivityFeed.feed(user_id) will now return an instance of ActivityFeed::Feed
* ActivityFeed::Ohm::Item will now return all of its attributes when calling to_json 

## 1.2

* Support aggregate feeds

## 1.1.1

* Removing activemodel dependency since that is not needed

## 1.1.0

* Added support for Ohm persistence, http://ohm.keyvalue.org
* Updated specs

## 1.0.0

* Initial release
