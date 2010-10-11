require 'curb'
require 'json'

module CouchClient
  class InvalidHTTPVerb < Exception; end
  class InvalidJSONData < Exception; end
    
  class Hookup
    attr_reader :handler
    
    def initialize(handler)
      @handler = handler
    end
    
    [:head, :get, :post, :put, :delete].each do |verb|
      define_method(verb) do |*args|
        curl(verb, *args)
      end
    end

    def inspect
      "#<#{self.class}>"
    end
    
    private
    
    def curl(verb, path = nil, query_data = {}, content_type = "application/json")
      options = lambda do |easy|
        easy.headers["User-Agent"] = "couch-client v#{VERSION}"
        easy.headers["Content-Type"] = content_type
        easy.headers["Accepts"] = content_type
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
        elsif content_type == "application/json"
          JSON.parse(easy.body_str)
        else
          easy.body_str
        end
      rescue
        raise InvalidJSONData.new("document received is not valid JSON")
      end
      
      [code, body]
    end
  end
end
