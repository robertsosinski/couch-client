module CouchClient
  class ViewNotFound < Exception; end
  class ShowNotFound < Exception; end
  class ListNotFound < Exception; end
  class FullTextNotFound < Exception; end

  class Design
    attr_accessor :id

    def initialize(id, connection)
      @id = id
      @connection = connection
    end

    def view(name, options = {})
      ["key", "startkey", "endkey"].each do |key|
        options[key] &&= options[key].to_json
      end

      code, body = @connection.hookup.get("_design/#{id}/_view/#{name}", options)

      case code
      when 200
        Collection.new(code, body, @connection)
      when 404
        raise ViewNotFound.new("could not find view field '#{name}' for design '#{id}'")
      else
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

    def fulltext(name, options = {})
      code, body = @connection.hookup.get("_fti/_design/#{id}/#{name}", options)

      case code
      when 200
        Collection.new(code, body, self)
      else
        if body["reason"] == "no_such_view"
          raise FullTextNotFound.new("could not find fulltext field '#{name}' for design '#{id}'")
        else
          raise Error.new("code: #{code}, error: #{body["error"]}, reason: #{body["reason"]}")
        end
      end
    end

    def inspect
      "#<#{self.class}: id: #{@id}>"
    end
  end
end
