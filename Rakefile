# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

desc "Run rubocop"
task :rubocop do
  sh "rubocop --extra-details --display-style-guide"
end

task default: [:spec, :rubocop]
