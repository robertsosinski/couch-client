module CouchClient
  class Connection
    class DatabaseNotGiven < Exception; end
    class DocumentNotValid < Exception; end
    
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
    
    def doc(id)
      code, body = @hookup.get(id)
      
      if body["_id"] && body["_rev"]
        Document.new(body, self)
      else
        raise bodyNotValid.new("the id '#{id}' does not correspond a valid body")
      end
    end
    
    alias_method :[], :doc
    
#    def build(*args)
#      raise ArgumentError.new("wrong number of arguments (#{args.size} for 2)") if args.size > 2
#      
#      one, two = args[0], args[1]
#      
#      id, fields = if one.is_a?(String) && two.is_a?(Hash)
#        [one, two]
#      elsif one.is_a?(String) && two.nil?
#        [one, {}]
#      elsif one.is_a?(Hash) && two.nil?
#        [nil, one]
#      elsif one.nil? && two.nil?
#        [nil, {}]
#      else
#        raise ArgumentError.new("invalid arguments, parameters must be an 'id' and/or 'fields'")
#      end
#      
#      document = Document.new({}, fields, self)
#      document.id = id if id
#      document
#    end
#    
#    def create(*args)
#      document = build(*args)
#      document.save
#      document
#    end
  end
end
