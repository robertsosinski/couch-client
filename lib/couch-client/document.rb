module CouchClient
  class Document < Hash
    attr_reader :error

    def initialize(body, connection)
      self.merge!(body)

      @connection = connection
      @error = {}
    end

    ["id", "rev", "attachments"].each do |method|
      define_method(method) do
        self["_#{method}"]
      end

      define_method("#{method}=") do |value|
        self["_#{method}"] = value
      end
    end

    def remote_doc
      @connection.doc(self.id)
      self
    end

    def update_doc
    end

    def update_rev
      self.rev = remote_doc.rev
      self
    end

    def save
      code, body = if self.id
        @connection.hookup.put(self.id, self)
      else
        @connection.hookup.post(self)
      end

      if body["ok"]
        self.id ||= body["id"]
        self.rev  = body["rev"]
        true
      else
        @error = {body["error"] => body["reason"]}
        false
      end
    end
  end
end
