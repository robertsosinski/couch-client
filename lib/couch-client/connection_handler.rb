require 'cgi'

module CouchClient
  class ConnectionHandler
    attr_accessor :scheme, :username, :password, :host, :port, :database
    
    def initialize
      @scheme = "http"
      @host = "localhost"
      @port = 5984
    end
    
    def uri(path = nil, query = nil)
      str  = "#{@scheme}://#{@host}:#{@port}/#{@database}"
      str += "/" + path if path
      str += "?" + encode(query) if query && !query.empty?
      str
    end
    
    def inspect
      head = "#<#{self.class}: "
      body = []
      body << "username: #{@username}" if @username
      body << "password: #{@password}" if @password
      body << "uri: #{self.uri}"
      tail = ">"
      
      head + body.join(", ") + tail
    end
    
    private
    
    def encode(hash)
      hash.to_a.map{|pair| pair.map{|p| CGI.escape(p)}.join("=")}.join("&")
    end
  end
end
