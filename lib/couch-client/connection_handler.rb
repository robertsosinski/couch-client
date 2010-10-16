module CouchClient
  class ConnectionHandler
    attr_accessor :scheme, :username, :password, :host, :port, :database

    def initialize
      @scheme = "http"
      @host = "localhost"
      @port = 5984
    end

    def uri(path_str = nil, query = nil)
      str  = "#{@scheme}://#{@host}:#{@port}"
      str += path(path_str, query)
      str
    end

    def path(path_str = nil, query = nil)
      str  = "/#{@database}"
      str += "/" + path_str if path_str
      str += "?" + encode(query) if query && !query.empty?
      str
    end

    def inspect
      "#<#{self.class}>"
    end

    private

    def encode(hash)
      hash.to_a.map{|pair| pair.join("=")}.join("&")
    end
  end
end
