require 'curb'
require 'json'

module CouchClient
  class Hookup
    class InvalidHTTPVerb < Exception; end
    class InvalidJSONData < Exception; end
    
    attr_reader :handler
    
    def initialize(handler)
      @handler = handler
    end
    
    def head(path = nil, query = {})
      curl(:head, path, query)
    end
    
    def get(path = nil, query = {})
      curl(:get, path, query)
    end
    
    def post(data = {})
      curl(:post, nil, data)
    end
    
    def put(path = nil, data = {})
      curl(:put, path, data)
    end
    
    def delete(path = nil, query = {})
      curl(:delete, path, query)
    end

    def inspect
      "#<#{self.class}: uri: #{@handler.uri}>"
    end
    
    private
    
    def curl(verb, path, query_data = {})
      options = lambda do |easy|
        easy.headers["User-Agent"] = "couch-client v#{VERSION}"
        easy.headers["Content-Type"] = "application/json"
        easy.headers["Accepts"] = "application/json"
        easy.username = handler.username
        easy.userpwd  = handler.password
      end
      
      easy = case verb
      when :head, :get, :delete
        Curl::Easy.send("http_#{verb}", handler.uri(path, query_data), &options)
      when :post, :put
        Curl::Easy.send("http_#{verb}", handler.uri(path), query_data.to_json, &options)
      else
        raise InvalidHTTPVerb.new("only `head`, `get`, `post`, `put` and `delete` are supported")
      end
      
      code = easy.response_code
      
      body = begin
        if easy.body_str == "" or easy.body_str.nil?
          nil
        else
          JSON.parse(easy.body_str)
        end
      rescue
        raise InvalidJSONData.new("document received is not valid JSON")
      end
      
      [code, body]
    end
  end
end
