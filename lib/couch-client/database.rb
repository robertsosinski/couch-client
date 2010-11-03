module CouchClient
  # Database is just an organized collection of functions that interact with the
  # CouchDB database such as stats, creation, compaction, replication and deletion.
  class Database
    # Database is constructed with a connection that is used to make HTTP requests to the server.
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
      @connection.hookup.post(["_compact"]).last
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
