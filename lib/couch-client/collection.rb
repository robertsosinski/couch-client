module CouchClient
  # The Document is an extended Array that provides additional methods
  # and state to get status codes, info and connect documents to the server.
  class Collection < Array
    attr_reader :code, :info
    
    # Collection is constructed with a status code, response body,
    # and connection object.
    def initialize(code, body, connection)
      # Iterate over each row to set them a CouchClient::Row object.
      body.delete("rows").each.with_index do |row, idx|
        self[idx] = Row.new(code, row, connection)
      end

      @code = code
      @info = body
      @connection = connection
    end
  end
end
