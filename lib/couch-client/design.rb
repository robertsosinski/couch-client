module CouchClient
  class ViewNotFound < Exception; end
  class ShowNotFound < Exception; end
  class ListNotFound < Exception; end
  class FullTextNotFound < Exception; end
  class FullTextRequestBad < Exception; end
  
  # Design is the interface used to interact with design documents
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
    
    # Makes requests to the server that return show objects.
    def show(name, document_id, options = {})
      code, body = @connection.hookup.get(["_design", id, "_show", name, document_id], options, nil)

      case code
      when 200
        body.is_a?(Hash) ? ConsistentHash.new(body) : body
      when 404
        # Raise an error if nothing was found
        raise ViewNotFound.new("could not find show field '#{name}' for design '#{id}'")
      else
        # Also raise an error if something else happens
        raise Error.new("code: #{code}, error: #{body["error"]}, reason: #{body["reason"]}")
      end
    end
    
    # Makes requests to the server that list objects.
    def list(name, document_id, view_name, options = {})
      code, body = @connection.hookup.get(["_design", id, "_list", name, document_id, view_name], options)

      case code
      when 200
        body.is_a?(Hash) ? ConsistentHash.new(body) : body
      when 404
        # Raise an error if nothing was found
        raise ViewNotFound.new("could not find list field '#{name}' for design '#{id}'")
      else
        # Also raise an error if something else happens
        raise Error.new("code: #{code}, error: #{body["error"]}, reason: #{body["reason"]}")
      end
    end
    
    # Makes requests to the server that return lucene search results.
    def fulltext(name, options = {})
      path = ["_fti", "_design", id, name]
      verb = :get
      
      # Options may be a Hash or a String.  Hashes are used for fulltext queries,
      # while String are used for administration operations (such as optimizing).
      if [String, Symbol].include?(options.class)
        path << "_#{options}"
        verb =  :post
        options = {}
      end
      
      code, body = @connection.hookup.send(verb, path, options)

      case code
      when 200
        if body["rows"]
          # Return a serch result if a query was provided.
          Collection.new(code, body, self)
        else
          # Return a status hash if a query was not provided.
          body
        end
      when 202
        true # Return true when administration operations are successfully performed.
      else
        case body["reason"]
        when "no_such_view"
          # Raise an error if a fulltext function was not found.
          raise FullTextNotFound.new("could not find fulltext field '#{name}' for design '#{id}'")
        when "bad_request"
          # Raise an error if a request was not formated properly (i.e. is bad).
          raise FullTextRequestBad.new("bad request made for fulltext field '#{name}' for design '#{id}'")
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
