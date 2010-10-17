require 'curb'
require 'json'

module CouchClient
  class InvalidHTTPVerb < Exception; end
  class InvalidJSONData < Exception; end

  # The Hookup is the basic HTTP interface that connects CouchClient to CouchDB.
  # Hookup can use any HTTP library if the conventions listed below are followed.
  #
  # If modified, Hookup must have head, get, post, put and delete instance methods.
  class Hookup
    attr_reader :handler
    
    # Hookup is constructed with a connection handler, which formats the 
    # proper URIs with domains, authentication settings and query strings.
    def initialize(handler)
      @handler = handler
    end
    
    # Hookup#(head|get|delete) has the following method signature
    #   hookup.verb("path", {"query_key" => "query_value"}, "content/type")
    #
    # And has the following response
    # [code, {"data_key" => "data_value"}]
    #
    # Except if the verb is `head`, which has the following response
    # [code, nil]
    #
    # Or if the verb is `get` and content_type is not "application/json", which has the following response
    # [code, "string containing file data"]
    #
    # By default path is nil, query is nil, and content_type is "application/json"
    [:head, :get, :delete].each do |verb|
      define_method(verb) do |*args|
        # These methods do not have a body parameter. As such, the following
        # prevents setting content_type to nil instead not setting it at all.
        params = [verb, args.shift, args.shift, nil]
        params << args.shift unless args.empty?
        curl(*params)
      end
    end
    
    # Hookup#(post|put) has the following method signature
    #   hookup.verb("path", {"query_key" => "query_value"}, {"data_key" => "data_value"}, "content/type")
    #
    # And has the following response
    # [code, {"data_key" => "data_value"}]
    #
    # By default path is nil, query is nil, data is {} and content_type is "application/json"
    [:post, :put].each do |verb|
      define_method(verb) do |*args|
        curl(verb, *args)
      end
    end

    def inspect
      "#<#{self.class}>"
    end
    
    private
    
    # This is the method that actually makes the curl request for each verb listed above.
    def curl(verb, path = nil, query = nil, data = {}, content_type = "application/json")
      # Setup curb options block
      options = lambda do |easy|
        easy.headers["User-Agent"] = "couch-client v#{VERSION}"
        easy.headers["Content-Type"] = content_type if content_type
        easy.headers["Accepts"] = content_type if content_type
        easy.username = handler.username
        easy.userpwd  = handler.password
      end
      
      easy = case verb
      when :head, :get, :delete
        # head, get and delete http methods only take a uri string and options block
        Curl::Easy.send("http_#{verb}", handler.uri(path, query), &options)
      when :post, :put
        # post and put http methods take a uri string, post string and options block
        # also convert the hash into json if the content_type of the request is json
        data = data.to_json if content_type == "application/json"
        Curl::Easy.send("http_#{verb}", handler.uri(path, query), data, &options)
      else
        raise InvalidHTTPVerb.new("only `head`, `get`, `post`, `put` and `delete` are supported")
      end
      
      # code is the http code (e.g. 200 or 404)
      code = easy.response_code
      
      # body is either a nil, a hash or a string containing attachent data
      body = if easy.body_str == "" || easy.body_str.nil?
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
