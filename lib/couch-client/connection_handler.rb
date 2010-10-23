require 'cgi'

module CouchClient
  class InvalidPathObject < Exception; end
  class InvalidQueryObject < Exception; end
  class InvalidDatabaseName < Exception; end
  
  # The ConnectionHandler creates properly formed URIs and paths, while also
  # specifying sensible defaults for CouchDB.  Once initialized, parameters
  # can be wrote and read using getter and setter syntax.
  class ConnectionHandler
    attr_accessor :scheme, :username, :password, :host, :port
    attr_reader :database
    
    # ConnectionHandler is constructed without any parameters, and with defaults
    # for scheme, host and port.  Other settings are set via the accessors above.
    def initialize
      @scheme = "http"
      @host = "localhost"
      @port = 5984
    end
    
    def database=(database)
      if database.match(/^[a-z0-9_$()+-\/]+$/)
        @database = database
      else
        raise InvalidDatabaseName.new("only lowercase characters (a-z), digits (0-9), or _, $, (, ), +, - and / are allowed.")
      end
    end
    
    # Creates a properly formed URI that can be used by a HTTP library.
    def uri(path_obj = nil, query_obj = nil)
      str  = "#{@scheme}://#{@host}:#{@port}"
      str += path(path_obj, query_obj)
      str
    end
    
    # Creates a properly formed path that can be used by a HTTP library.
    # `path_obj` can be an Array or NilClass, `query_obj` can be Hash or NilClass.
    def path(path_obj = nil, query_obj = nil)
      path_obj ||= []
      
      path_str = case path_obj
      when Array
        # If an Array, stringify and escape (unless it is a design document) each object and join with a "/"
        ([@database] + path_obj).map{|p| p.to_s.match(/_design\//) ? p.to_s : CGI.escape(p.to_s)}.join("/")
      else
        # Else, raise an error
        raise InvalidPathObject.new("path must be of type 'Array' not of type '#{path_obj.class}'")
      end
      
      query_str = case query_obj
      when Hash
        # If a Hash, stringify and escape each object, join each key/value with a "=" and each pair with a "&"
        query_obj.to_a.map{|q| q.map{|r| CGI.escape(r.to_s)}.join("=")}.join("&")
      when NilClass
        # If a NilClass, make an empty string
        ""
      else
        # Else, raise an error
        raise InvalidQueryObject.new("path must be of type 'Hash' or 'NilClass' not of type '#{query_obj.class}'")
      end
      
      str  = "/" + path_str
      str += "?" + query_str unless query_str.empty?
      str
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end
