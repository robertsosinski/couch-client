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

    [:head, :get, :delete].each do |verb|
      define_method(verb) do |*args|
        params = [verb, args.shift, args.shift, nil]
        params << args.shift unless args.empty?
        curl(*params)
      end
    end

    [:post, :put].each do |verb|
      define_method(verb) do |*args|
        curl(verb, *args)
      end
    end

    def inspect
      "#<#{self.class}>"
    end
    
    private
    
    def curl(verb, path = nil, query = nil, data = {}, content_type = "application/json")
      options = lambda do |easy|
        easy.headers["User-Agent"] = "couch-client v#{VERSION}"
        easy.headers["Content-Type"] = content_type if content_type
        easy.headers["Accepts"] = content_type if content_type
        easy.username = handler.username
        easy.userpwd  = handler.password
      end
      
      easy = case verb
      when :head, :get, :delete
        Curl::Easy.send("http_#{verb}", handler.uri(path, query), &options)
      when :post, :put
        data = data.to_json if content_type == "application/json"
        Curl::Easy.send("http_#{verb}", handler.uri(path, query), data, &options)
      else
        raise InvalidHTTPVerb.new("only `head`, `get`, `post`, `put` and `delete` are supported")
      end
      
      code = easy.response_code
      
      body = if easy.body_str == "" or easy.body_str.nil?
        nil
      elsif content_type == "application/json" || [:post, :put, :delete].include?(verb)
        begin
          JSON.parse(easy.body_str)
        rescue
          raise InvalidJSONData.new("document received is not valid JSON")
        end
      else
        easy.body_str
      end
      
      [code, body]
    end
  end
end
