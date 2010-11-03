module CouchClient
  # Attachment is an extended Hash that provides additional methods
  # to interact with attached files saved within a document.
  class Attachment < ConsistentHash
    attr_reader :name

    # Attachment is constructed with the id of the document it is attached to,
    # the filename, file stub and connection object.
    def initialize(id, name, stub, connection)
      self.merge!(stub)

      @id = id
      @name = name
      @connection = connection
    end
    
    # Returns the path for the attachment
    def path
      @connection.hookup.handler.path([@id, @name])
    end

    # Returns the uri for the attachment
    def uri
      @connection.hookup.handler.uri([@id, @name])
    end

    # Returns a string that contains attachment data
    def data
      @data ||= @connection.hookup.get([@id, @name], nil, self["content_type"]).last
    end
  end
end
