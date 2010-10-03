module CouchClient
  class Document < Hash
    attr_reader :code, :error

    def initialize(code, body, connection)
      self.merge!(body)

      @code = code
      @error = {}
      @connection = connection
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
      @connection[self.id]
    end

    def save
      @code, body = if self.id
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

    def design?
      !!self.id.match(/_design\//)
    end

    def error?
      !!self.error
    end

    def conflict?
      !!self.error["conflict"]
    end
  end
end
