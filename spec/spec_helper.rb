require 'rubygems'
require 'rspec'

Rspec.configure do |c|
  c.mock_with :rspec
end

COUCHDB_TEST_SETTINGS = {:database => "couch-client_test"}
COUCHDB_TEST_DATABASE = COUCHDB_TEST_SETTINGS[:database]

require File.join(File.dirname(File.expand_path(__FILE__)), "..", "lib", "couch-client")
