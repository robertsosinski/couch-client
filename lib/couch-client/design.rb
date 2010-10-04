module CouchClient
  class Design
    class CollectionNotFound < Exception; end

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
        Collection.new(code, body, self)
      when 404
        raise CollectionNotFound.new("a map/reduce function could not be found for design id '#{id}' and view name '#{name}'")
      else
        raise Error.new("code: #{code}, error: #{body["error"]}, reason: #{body["reason"]}")
      end
    end

    def inspect
      "#<#{self.class}: id: #{@id}>"
    end
  end
end
