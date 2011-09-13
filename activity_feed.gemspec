# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'activity_feed/version'

Gem::Specification.new do |s|
  s.name        = 'activity_feed'
  s.version     = ActivityFeed::VERSION
  s.authors     = ['David Czarnecki']
  s.email       = ['dczarnecki@agoragames.com']
  s.homepage    = 'https://github.com/agoragames/activity_feed'
  s.summary     = %q{Activity Feeds with MongoDB and Redis}
  s.description = %q{Activity Feeds with MongoDB and Redis}

  s.rubyforge_project = 'activity_feed'

  s.files         = `git ls-files`.split('\n')
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split('\n')
  s.executables   = `git ls-files -- bin/*`.split('\n').map{ |f| File.basename(f) }
  s.require_paths = ['lib']
  
  s.add_development_dependency('rspec')
  s.add_development_dependency('database_cleaner')
  s.add_development_dependency('fabrication')

  s.add_dependency('activesupport')
  s.add_dependency('i18n')
  
  s.add_dependency('mongo_mapper')
  s.add_dependency('mongo_ext')
  s.add_dependency('bson_ext')
  s.add_dependency('redis')
  s.add_dependency('leaderboard')
end
