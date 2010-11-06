require 'rake'
require 'rspec/core/rake_task'
require 'echoe'

# Prevent Echoe from running spec tasks, especially as
# spec should be removed in later versions of Rspec 2.
Object.send(:remove_const, :Spec)

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w[--colour --format progress]
end

Echoe.new("couch-client") do |p|
  p.author = "Robert Sosinski"
  p.email = "email@robertsosinski.com"
  p.url = "http://github.com/robertsosinski/couch-client"
  p.description = "CouchClient is Ruby library that can be used to interact with CouchDB"
  p.summary = "The goal of CouchClient is to make documents feel as much as possible what they already represent: a Hash of primitives, Arrays and other Hashes."
  p.runtime_dependencies = ["json >=1.4.6", "curb >=0.7.8"]
end