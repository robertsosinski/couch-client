require 'cgi'

module CouchClient
  class InvalidPathObject < Exception; end
  class InvalidQueryObject < Exception; end
  
  # The ConnectionHandler creates properly formed URIs and paths, while also
  # specifying sensible defaults for CouchDB.  Once initialized, parameters
  # can be wrote and read using getter and setter syntax.
  class ConnectionHandler
    attr_accessor :scheme, :username, :password, :host, :port, :database

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

    # Creates a properly formed ath that can be used by a HTTP library.
    def path(path_obj = nil, query_obj = nil)
      # A path_obj can be an Array, String or NilClass
      path_str = case path_obj
      when Array
        # If an Array, escape each object and join with a "/"
        path_obj.map{|p| CGI.escape(p.to_s)}.join("/")
      when String
        # If a String, escape it without escaping "/" characters
        CGI.escape(path_obj).gsub("%2F", "/")
      when NilClass
        # If a NilClass, make an empty string
        ""
      else
        # Else, raise an error
        raise InvaliPathObject.new("path must be of type 'Array', 'String' or 'NilClass', not of type '#{path_obj.class}'")
      end
      
      # A query_obj can be a Hash or NilClass
      query_str = case query_obj
      when Hash
        # If a Hash, escape each object, join each key/value with a "=" and each pair with a "&"
        query_obj.to_a.map{|q| q.map{|r| CGI.escape(r)}.join("=")}.join("&")
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
