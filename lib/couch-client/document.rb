module CouchClient
  class AttachmentError < Exception; end
  class InvalidId < Exception; end

  class Document < Hash
    attr_reader :code, :error

    def initialize(code, body, connection, deleted = false)
      self.merge!(body)

      @code = code
      @error = {}
      @connection = connection
      @deleted = deleted

      if self.attachments
        self.attachments.keys.each do |key|
          self.attachments[key] = Attachment.new(id, key, attachments[key], @connection)
        end
      end
    end

    ["id", "rev", "attachments"].each do |method|
      define_method(method) do
        self["_#{method}"]
      end

      define_method("#{method}=") do |value|
        self["_#{method}"] = value
      end
    end
    
    def saved_doc(query = {})
      @connection[self.id, query]
    end

    def refresh(query = {})
      doc = @connection[self.id, query]
      self.clear
      self.merge!(doc)
      self
    end

    def save
      # Ensure that "_id" is a String if it is defined.
      if self.key?("_id") && !self["_id"].is_a?(String)
        raise InvalidId.new("document _id must be a String")
      end
      
      @code, body = if self.id
        @connection.hookup.put(self.id, {}, self)
      else
        @connection.hookup.post(nil, {}, self)
      end

      if body["ok"]
        self.id ||= body["id"]
        self.rev  = body["rev"]
        @deleted = false
        true
      else
        @error = {body["error"] => body["reason"]}
        false
      end
    end

    def attach(name, content, content_type)
      if self.rev
        @code, body = @connection.hookup.put("#{self.id}/#{name}", {"rev" => self.rev}, content, content_type)
        
        if body["ok"]
          self.rev = body["rev"]
          true
        else
          @error = {body["error"] => body["reason"]}
          false
        end
      else
        raise AttachmentError.new("a document must exist before an attachment can be uploaded to it")
      end
    end

    def delete!
      @code, body = @connection.hookup.delete(id, {"rev" => rev})
      
      if body["ok"]
        self.rev = body["rev"]
        @deleted = true
        true
      else
        @error = {body["error"] => body["reason"]}
        false
      end
    end

    def design?
      !!self.id.match(/_design\//)
    end

    def error?
      !@error.empty?
    end
    
    def valid?
      !(@code == 403 && @error["forbidden"])
    end
    
    def invalid?
      !valid?
    end

    def conflict?
      !!@error["conflict"]
    end

    def deleted?
      @deleted
    end
  end
end
