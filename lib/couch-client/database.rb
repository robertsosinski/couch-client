module CouchClient
  class Database
    def initialize(connection)
      @connection = connection
    end

    def stats
      @connection.hookup.get.last
    end

    def exists?
      @connection.hookup.get.first == 200
    end

    def create
      @connection.hookup.put.last
    end

    def delete!
      @connection.hookup.delete.last
    end

    def compact!
      @connection.hookup.post("_compact").last
    end

    # TODO: add replicate method
    def replicate
      raise "pending"
    end

    def inspect
      "#<#{self.class}>"
    end
  end
end
