module CouchClient
  class Row < Hash
    def initialize(code, row, connection)
      self["id"] = row["id"] if row["id"]
      self["doc"] = Document.new(code, row["doc"], connection) if row["doc"]
      self["key"] = row["key"]
      self["value"] = row["value"]
    end

    ["id", "key", "value", "doc"].each do |method|
      define_method(method) do
        self[method]
      end
    end
  end
end
