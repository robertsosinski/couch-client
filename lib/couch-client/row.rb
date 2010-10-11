module CouchClient
  class Row < Hash
    def initialize(code, row, connection)
      self.merge!(row)
      self["doc"] &&= Document.new(code, row["doc"], connection)
    end
  end
end
