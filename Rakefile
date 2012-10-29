require 'bundler'
Bundler::GemHelper.install_tasks

require 'rake'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec) do |spec|
  spec.pattern = 'spec/**/*_spec.rb'
  spec.rspec_opts = ['--backtrace']
  # spec.ruby_opts = ['-w']
end

task :default  => :spec

desc "Run the specs against Ruby 1.8.7 and 1.9.3"
task :test_rubies do
  system "rvm ruby-1.8.7@activity_feed_gem,ruby-1.9.3@activity_feed_gem do rake spec"
end