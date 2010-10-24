module CouchClient
  class InvalidId < Exception; end
  class AttachmentError < Exception; end
  class DocumentNotAvailable < Exception; end
  
  # The Document is an extended Hash that provides additional methods to
  # save, update (with attachments), and delete documents on the CouchDB.
  class Document < Hash
    attr_reader :code, :error

    # Document is constructed with a status code, response body,
    # connection object and a flag stating if the document has been deleted.
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

    # Hookup#(id|id=|rev|rev=|attachments|attachments=) are convenience methods
    # that correspond to ["_id"], ["_rev"] and ["_attachments"] document fields.
    ["id", "rev", "attachments"].each do |method|
      define_method(method) do
        self["_#{method}"]
      end

      define_method("#{method}=") do |value|
        self["_#{method}"] = value
      end
    end
    
    # Returns a copy of the same document that is currently saved on the server.
    def saved_doc(query = {})
      if new?
        raise DocumentNotAvailable.new('this document is new and therefore has not been saved yet')
      else
        @connection[self.id, query]
      end
    end

    # Tries to save the document to the server.  If it us unable to,
    # it will save the error and make it available with via #error.
    def save
      # Ensure that "_id" is a String if it is defined.
      if self.key?("_id") && !self["_id"].is_a?(String)
        raise InvalidId.new("document _id must be a String")
      end
      
      # Documents without an id must use post, with an id must use put
      @code, body = if self.id
        @connection.hookup.put([self.id], nil, self)
      else
        @connection.hookup.post(nil, nil, self)
      end
      
      # If the document was saved
      if body["ok"]
        # Update id and rev, ensure the deleted flag is set to `false` and return `true`
        self.id ||= body["id"]
        self.rev  = body["rev"]
        @deleted  = false
        true
      else
        # Save error message and return `false`.
        @error = {body["error"] => body["reason"]}
        false
      end
    end

    # Tries to attach a file to the document.  If it us unable to,
    # it will save the error and make it available with via #error.
    def attach(name, content, content_type)
      # The document must already be saved to the server before a file can be attached.
      if self.rev
        @code, body = @connection.hookup.put([self.id, name], {"rev" => self.rev}, content, content_type)
        
        # If the document was saved
        if body["ok"]
          # Update rev and return `true`
          self.rev = body["rev"]
          true
        else
          # Save error message and return `false`.
          @error = {body["error"] => body["reason"]}
          false
        end
      else
        # Raise an error if the document is new before trying to attach a file.
        raise AttachmentError.new("a document must exist before an attachment can be uploaded to it")
      end
    end
    
    # Tries to delete a file from the server.  If it us unable to,
    # it will save the error and make it available with via #error.
    def delete!
      @code, body = @connection.hookup.delete([id], {"rev" => rev})
      
      # If the document was deleted
      if body["ok"]
        # Update the rev, set the deleted flag to `true` and return `true`
        self.rev = body["rev"]
        @deleted = true
        true
      else
        # Save error message and return `false`.
        @error = {body["error"] => body["reason"]}
        false
      end
    end

    # Identifies the document as a design document
    def design?
      !!self.id.match(/_design\//) # Design documents start with "_design/"
    end
    
    # Identifies the document as not yet being saved to the server
    def new?
      !rev
    end

    # Identifies that there are currently errors that must be resolved
    def error?
      !@error.empty?
    end
    
    # Identifies that the document does not yet pass a `validate_on_update` function
    def invalid?
      @code == 403 && @error["forbidden"]
    end
    
    # Identifies that the document cannot be saved due to conflicts
    def conflict?
      !!@error["conflict"]
    end

    # Identifies that the document has been deleted
    def deleted?
      @deleted
    end
  end
end
