$:.unshift(File.dirname(File.expand_path(__FILE__)))

require 'couch-client/hookup'
require 'couch-client/connection'
require 'couch-client/connection_handler'
require 'couch-client/document'
require 'couch-client/collection'

module CouchClient
  VERSION = "0.0.1"
  
  def self.connect(args = {}, &block)
    Connection.new(args, &block)
  end
end
