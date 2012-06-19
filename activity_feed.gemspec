# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'activity_feed/version'

Gem::Specification.new do |s|
  s.name        = 'activity_feed'
  s.version     = ActivityFeed::VERSION
  s.authors     = ['David Czarnecki']
  s.email       = ['dczarnecki@agoragames.com']
  s.homepage    = 'https://github.com/agoragames/activity_feed'
  s.summary     = %q{Activity feeds backed by Redis}
  s.description = %q{Activity feeds backed by Redis}

  s.rubyforge_project = 'activity_feed'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  
  s.require_paths = ['lib']
  
  s.add_development_dependency('rake')
  s.add_development_dependency('rspec')
  s.add_development_dependency('activesupport')
  s.add_development_dependency('timecop')

  s.add_development_dependency('mongoid')
  s.add_development_dependency('bson_ext')

  s.add_development_dependency('activerecord')
  s.add_development_dependency('sqlite3')
  
  s.add_development_dependency('database_cleaner')
   
  s.add_dependency('leaderboard')
end
