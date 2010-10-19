require 'cgi'

module CouchClient
  class InvalidPathObject < Exception; end
  class InvalidQueryObject < Exception; end
  
  # The ConnectionHandler creates properly formed URIs and paths, while also
  # specifying sensible defaults for CouchDB.  Once initialized, parameters
  # can be wrote and read using getter and setter syntax.
  class ConnectionHandler
    attr_accessor :scheme, :username, :password, :host, :port, :database
    
    # ConnectionHandler is constructed without any parameters, and with defaults
    # for scheme, host and port.  Other settings are set via the accessors above.
    def initialize
      @scheme = "http"
      @host = "localhost"
      @port = 5984
    end
    
    # Creates a properly formed URI that can be used by a HTTP library.
    def uri(path_obj = nil, query_obj = nil)
      str  = "#{@scheme}://#{@host}:#{@port}"
      str += path(path_obj, query_obj)
      str
    end
    
    # Creates a properly formed path that can be used by a HTTP library.
    def path(path_obj = nil, query_obj = nil)
      # A path_obj can be an Array, String or NilClass
      path_str = case path_obj
      when Array
        # If an Array, stringify and escape (unless it is a design document) each object and join with a "/"
        path_obj.map.with_index{|p, i| (i == 0 && p.to_s.match(/_design\//)) ? p.to_s : CGI.escape(p.to_s)}.join("/")
      when NilClass
        # If a NilClass, make an empty string
        ""
      else
        # Else, raise an error
        raise InvalidPathObject.new("path must be of type 'Array', or 'NilClass', not of type '#{path_obj.class}'")
      end
      
      # A query_obj can be a Hash or NilClass
      query_str = case query_obj
      when Hash
        # If a Hash, stringify and escape each object, join each key/value with a "=" and each pair with a "&"
        query_obj.to_a.map{|q| q.map{|r| CGI.escape(r.to_s)}.join("=")}.join("&")
      when NilClass
        # If a NilClass, make an empty string
        ""
      else
        # Else, raise an error
        raise InvalidQueryObject.new("path must be of type 'Hash' or 'NilClass', not of type '#{query_obj.class}'")
      end
      
      str  = "/#{@database}"
      str += "/" + path_str unless path_str.empty?
      str += "?" + query_str unless query_str.empty?
      str
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end
