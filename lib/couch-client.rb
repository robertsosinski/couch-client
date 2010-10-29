$:.unshift(File.dirname(File.expand_path(__FILE__)))

# require '../core_ext/hash'

require 'couch-client/consistent_hash'
require 'couch-client/connection'
require 'couch-client/connection_handler'
require 'couch-client/hookup'
require 'couch-client/database'
require 'couch-client/document'
require 'couch-client/attachment_list'
require 'couch-client/attachment'
require 'couch-client/design'
require 'couch-client/collection'
require 'couch-client/row'

# The CouchClient module is the overall container of all CouchClient logic.
module CouchClient
  VERSION = "0.0.1"
  
  class Error < Exception; end
  
  # Start using CouchClient by constructing a new CouchClient::Connection object with a Hash:
  #
  #   CouchClient.connect(:database => "db_name")
  #
  # with a block:
  #
  #   CouchClient.connect do |c|
  #     c.database = "db_name"
  #   end
  #
  # or with both:
  #
  #   CouchClient.connect(:username => "user", :password => "pass") do |c|
  #     c.database = "db_name"
  #   end
  #
  # CouchClient.connect takes the following options.
  #
  #  scheme: Protocol used (e.g. http or https), default being "http".
  #  username: Username used by HTTP Basic authentication.
  #  password: Password used by HTTP Basic authentication.
  #  host: The domain for your CouchDB erver, default being "localhost".
  #  port: The port for your CouchDB server, default being 5984.
  #  database: The database you wish to connect to.
  def self.connect(args = {}, &block)
    Connection.new(args, &block)
  end
end
