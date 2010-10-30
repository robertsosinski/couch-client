require 'rake'
require 'rspec/core/rake_task'
require 'echoe'

desc  "Run all specs"
RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w[--colour --format progress]
end

Echoe.new("couch-client") do |p|
  p.author = "Robert Sosinski"
  p.summary = "A CouchDB Ruby Client"
  p.url = "http://github.com/robertsosinski/couch-client"
  p.runtime_dependencies = ["json"]
end