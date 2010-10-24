module CouchClient
  # The Row is an extended Hash that provides additional state to 
  # get status codes and connect documents to the server.
  class Row < Hash
    def initialize(code, row, connection)
      self.merge!(row)
      self["doc"] &&= Document.new(code, row["doc"], connection)
    end
  end
end
