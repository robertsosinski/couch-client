require 'rake'
require 'rspec/core/rake_task'
require 'echoe'

desc "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w[--colour --format progress]
end

namespace :echoe do
  Echoe.new("couch-client") do |p|
    p.author = "Robert Sosinski"
    p.email = "email@robertsosinski.com"
    p.url = "http://github.com/robertsosinski/couch-client"
    p.description = "CouchClient is Ruby library that can be used to interact with CouchDB"
    p.summary = "The goal of CouchClient is to make documents feel as much as possible what they already represent: a Hash of primitives, Arrays and other Hashes."
    p.runtime_dependencies = ["json >=1.4.6", "curb >=0.7.8"]
  end
end