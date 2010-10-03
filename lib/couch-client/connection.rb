module CouchClient
  class Connection
    attr_reader :hookup
    
    def initialize(args = {})
      handler = ConnectionHandler.new
      
      if block_given?
        yield(handler)
      end
      
      args.each_pair do |key, value|
        handler.send("#{key}=", value)
      end
      
      unless handler.database
        raise DatabaseNotGiven.new("specify a database to connect to")
      end
      
      @hookup = Hookup.new(handler)
    end
    
    def [](id)
      code, body = @hookup.get(id)

      case code
      when 200
        if body["_id"] && body["_rev"]
          Document.new(code, body, self)
        else
          raise DocumentNotValid.new("the id '#{id}' does not correspond to a document")
        end
      when 404
        raise DocumentNotFound.new("a document could not be found with id '#{id}'")
      else
        raise Error.new("code: #{code}, error: #{body["error"]}, reason: #{body["reason"]}")
      end
    end

    def design(id)
      Design.new(id, self)
    end

    def build(body = {})
      Document.new(nil, body, self)
    end
    
    def create(body = {})
      document = build(body)
      document.save
      document
    end

    def inspect
      "#<#{self.class}: uri: #{@hookup.handler.uri}>"
    end
  end
end
