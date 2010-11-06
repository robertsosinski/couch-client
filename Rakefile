require 'rake'
require 'rspec/core/rake_task'
require 'echoe'

# Prevent Echoe from running spec tasks, especially as
# Spec should be removed in later versions of Rspec 2.
Object.send(:remove_const, :Spec)

RSpec::Core::RakeTask.new do |t|
  t.rspec_opts = %w[--colour --format progress]
end

Echoe.new("couch-client") do |p|
  p.author = "Robert Sosinski"
  p.email = "email@robertsosinski.com"
  p.url = "http://github.com/robertsosinski/couch-client"
  p.description = "A Ruby interface for CouchDB"
  p.summary = "A Ruby interface for CouchDB that provides easy configuration, state management and utility methods."
  p.runtime_dependencies = ["json >=1.4.6", "curb >=0.7.8"]
  p.development_dependencies = ["echoe >=4.3.1", "rspec >=2.0.0"]
end