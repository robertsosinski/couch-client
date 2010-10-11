module CouchClient
  class Collection < Array
    attr_reader :code, :info

    def initialize(code, body, connection)
      body.delete("rows").each.with_index do |row, idx|
        self[idx] = Row.new(code, row, connection)
      end

      @code = code
      @info = body
      @connection = connection
    end
  end
end
