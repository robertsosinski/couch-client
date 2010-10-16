require 'rubygems'
require 'rspec'

Rspec.configure do |c|
  c.mock_with :rspec
end

require File.join(File.dirname(File.expand_path(__FILE__)), "..", "lib", "couch-client")
