require 'rubygems'
require 'tempfile'
require 'rspec'
require 'rake'

Rspec.configure do |c|
  c.mock_with :rspec
end

COUCHDB_TEST_SETTINGS = {:database => "couch-client_test"}
COUCHDB_TEST_DATABASE = COUCHDB_TEST_SETTINGS[:database]

def suppress
  temp_f = Tempfile.new("suppress")
  save_stdout = $stdout.dup
  save_stderr = $stderr.dup
  begin
    $stdout.reopen(temp_f)
    $stderr.reopen(temp_f)
    yield
  rescue
    temp_f.flush
    save_stdout.puts File.open(temp_f.path).read
    raise
  ensure
    $stdout.reopen(save_stdout)
    $stderr.reopen(save_stderr)
  end
end

require File.join(File.dirname(File.expand_path(__FILE__)), "..", "lib", "couch-client")
