module CouchClient
  class Collection < Array
    attr_reader :code, :total_rows, :offset

    def initialize(code, body, connection)
      body["rows"].each.with_index do |row, idx|
        self[idx] = Row.new(code, row, connection)
      end

      @code = code
      @offset = body["offset"]
      @total_rows = body["total_rows"]
      @connection = connection
    end

    def reduced?
      !total_rows && !offset
    end
  end
end
