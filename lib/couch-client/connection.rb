module CouchClient
  class DatabaseNotGiven < Exception; end
  class DocumentNotValid < Exception; end
  class DocumentNotFound < Exception; end

  # The Connection is the high-level interface used to interact with the CouchDB Server.
  class Connection
    attr_reader :hookup, :database

    # Connection is constructed with a Hash or with a block specifying connection parameters.
    # An error will be raised if a database is not specified.
    def initialize(args = {})
      handler = ConnectionHandler.new
      
      # Set ConnectionHandler settings via a block
      if block_given?
        yield(handler)
      end
      
      # Set remaining ConnectionHandler settings via a Hash
      args.each_pair do |key, value|
        handler.send("#{key}=", value)
      end
      
      # Ensure a database is provided
      unless handler.database
        raise DatabaseNotGiven.new("specify a database to connect to")
      end
      
      # `@hookup` is used as the HTTP interface and `@database` is a namespace for all
      # database specific commands such as creation, deletion, compaction and replication.
      @hookup = Hookup.new(handler)
      @database = Database.new(self)
    end

    # Fetches documents from the CouchDB server. Although `[]` makes get requests and therefore
    # could fetch design views and more, anything received that is not a valid document will
    # raise an error.  As such, fetching designs can only be done through the `design` method.
    def [](id, options = {})
      code, body = @hookup.get([id], options)

      case code
      # If something was found
      when 200
        # And that something is a document
        if body["_id"] && body["_rev"]
          # Make a new document object
          Document.new(code, body, self)
        else
          # Else raise an error as `[]` should only return document objects
          raise DocumentNotValid.new("the id '#{id}' does not correspond to a document")
        end
      # If nothing was found
      when 404
        case body["reason"]
        # Because the document was deleted
        when "deleted"
          # Tell the user it was deleted
          raise DocumentNotFound.new("the document with id '#{id}' has been deleted")
        else
          # Else tell the user it was never there to begin with
          raise DocumentNotFound.new("a document could not be found with id '#{id}'")
        end
      # If something else happened
      else
        # Raise an error
        raise Error.new("code: #{code}, error: #{body["error"]}, reason: #{body["reason"]}")
      end
    end

    # Constructs a new design factory that manages `views`, `shows`, `lists` and `fulltext` searches.
    def design(id)
      Design.new(id, self)
    end
    
    # Acts as the interface to CouchDB's `_all_docs` map view.
    def all_docs(options = {})
      # key, startkey and endkey must be JSON encoded
      ["key", "startkey", "endkey"].each do |key|
        options[key] &&= options[key].to_json
      end
      
      # Create a new Collection with the response code, body and connection.
      Collection.new(*@hookup.get(["_all_docs"], options), self)
    end
    
    # Returns a list of all _design documents.
    def all_design_docs(options = {})
      all_docs({"startkey" => "_design/", "endkey" => "_design0"}.merge(options))
    end
    
    # The interface used to construct new CouchDB documents.  Once constructed
    # these documents can be saved, updated, validated and deleted.
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
