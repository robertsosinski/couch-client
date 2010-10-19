module CouchClient
  class ViewNotFound < Exception; end
  class ShowNotFound < Exception; end
  class ListNotFound < Exception; end
  class FullTextNotFound < Exception; end
  
  # The Design is the interface used to interact with design documents
  # in order make view, show, list and fulltext requests.
  class Design
    attr_accessor :id
    
    # Design is constructed with an id of the design documemnt and
    # a connection that is used to make HTTP requests to the server.
    def initialize(id, connection)
      @id = id
      @connection = connection
    end

    # Makes requests to the server that return mappped/reduced view collections.
    def view(name, options = {})
      # key, startkey and endkey must be JSON encoded
      ["key", "startkey", "endkey"].each do |key|
        options[key] &&= options[key].to_json
      end

      code, body = @connection.hookup.get(["_design", id, "_view", name], options)

      case code
      when 200
        # Return a Collection if results were found
        Collection.new(code, body, @connection)
      when 404
        # Raise an error if nothing was found
        raise ViewNotFound.new("could not find view field '#{name}' for design '#{id}'")
      else
        # Also raise an error if something else happens
        raise Error.new("code: #{code}, error: #{body["error"]}, reason: #{body["reason"]}")
      end
    end

    # TODO: add show method
    def show(name, options = {})
      raise "pending"
    end

    # TODO: add list method
    def list(name, options = {})
      raise "pending"
    end
    
    # Makes requests to the server that return lucene search results.
    def fulltext(name, options = {})
      code, body = @connection.hookup.get(["_fti", "_design", id, name], options)

      case code
      when 200
        if body["rows"]
          # Return a serch result if a query was provided
          Collection.new(code, body, self)
        else
          # Return a status hash if a query was not provided
          body
        end
      else
        if body["reason"] == "no_such_view"
          # Raise an error if a fulltext function was not found
          raise FullTextNotFound.new("could not find fulltext field '#{name}' for design '#{id}'")
        else
          # Also raise an error if something else happens 
          raise Error.new("code: #{code}, error: #{body["error"]}, reason: #{body["reason"]}")
        end
      end
    end

    def inspect
      "#<#{self.class}: id: #{@id}>"
    end
  end
end
