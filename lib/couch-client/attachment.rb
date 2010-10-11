module CouchClient
  class Attachment < Hash
    attr_reader :name

    def initialize(id, name, stub, connection)
      self.merge!(stub)

      @id = id
      @name = name
      @connection = connection
    end

    def file
      @connection.hookup.get("#{@id}/#{@name}", {}, self["content_type"]).last
    end

    def path
      "/#{@connection.hookup.handler.database}/#{@id}/#{@name}"
    end

    def uri
      @connection.hookup.handler.uri("#{@id}/#{@name}")
    end
  end
end
