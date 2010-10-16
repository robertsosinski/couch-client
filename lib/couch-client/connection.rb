module CouchClient
  class DatabaseNotGiven < Exception; end
  class DocumentNotValid < Exception; end
  class DocumentNotFound < Exception; end

  class Connection
    attr_reader :hookup, :database

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
      @database = Database.new(self)
    end

    def [](id, query = {})
      code, body = @hookup.get(id, query)

      case code
      when 200
        if body["_id"] && body["_rev"]
          Document.new(code, body, self)
        else
          raise DocumentNotValid.new("the id '#{id}' does not correspond to a document")
        end
      when 404
        case body["reason"]
        when "deleted"
          raise DocumentNotFound.new("the document with id '#{id}' has been deleted")
        else
          raise DocumentNotFound.new("a document could not be found with id '#{id}'")
        end
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

    def inspect
      head = "#<#{self.class}: "
      body = []
      body << "username: #{@hookup.handler.username}" if @hookup.handler.username
      body << "password: #{@hookup.handler.password}" if @hookup.handler.password
      body << "uri: #{@hookup.handler.uri}"
      tail = ">"

      head + body.join(", ") + tail
    end
  end
end
