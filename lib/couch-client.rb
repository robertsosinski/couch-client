$:.unshift(File.dirname(File.expand_path(__FILE__)))

# The CouchClient module is the overall container of all CouchClient logic.
module CouchClient
  VERSION = "0.0.1"
  
  begin
    # Require HashWithIndifferentAccess gem if available.
    require 'active_support/hash_with_indifferent_access'
    class Hash < ActiveSupport::HashWithIndifferentAccess
      private
      # Patching `convert_value` method, else it will absorb all "Hashlike"
      # objects and convert them into a HashWithIndifferentAccess.
      # NOTE: As this is patching a private method, this is probably not a good idea.
      def convert_value(value)
        if value.instance_of?(::Hash) # specifying Ruby's Hash, not CouchClient's Hash
          self.class.new_from_hash_copying_default(value)
        elsif value.instance_of?(Array)
          value.collect { |e| e.instance_of?(::Hash) ? self.class.new_from_hash_copying_default(e) : e }
        else
          value
        end
      end
    end
  rescue LoadError
    # If HashWithIndifferentAccess is not available, use Hash.
    class Hash < ::Hash; end
  end
  
  # requiring libraries inside of the CouchClient library so they can use
  # HashWithIndifferentAccess instead of Hash if it is available.
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
