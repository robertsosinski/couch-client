module CouchClient
  class Connection
    class DatabaseNotGiven < Exception; end
    class DocumentNotValid < Exception; end
    class DocumentNotFound < Exception; end

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
    
    def save(body = {})
      document = build(body)
      document.save
      document
    end

    def delete(id, rev)
      code, status = @hookup.delete(id, {"rev" => rev})
      Document.new(code, {"_id" => id, "_rev" => status["rev"]}, self, true)
    end

    def status
      @hookup.get.last
    end

    def database_exists?
      @hookup.get.first == 200
    end

    def create_database
      @hookup.put.last
    end

    def delete_database!
      @hookup.delete.last
    end

    def inspect
      "#<#{self.class}: uri: #{@hookup.handler.uri}>"
    end
  end
end
