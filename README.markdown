Introduction
============

CouchClient is Ruby library that can be used to interact with CouchDB.  The goal of CouchClient is to make documents feel as much as possible as what they already represent, a Hash of primitives, Arrays and other Hashes.  As such, the interface for documents already closely represents that of Hashes and Array, but also includes additional methods and state in order to interface easily with the CouchDB Server.

Connecting to CouchDB
---------------------
    
    # Using hash syntax
    Couch = CouchClient::Conection.new({
      :scheme   => "http",
      :host     => "localhost",
      :port     => 5984,
      :database => "sandbox",
      :username => "admin",
      :password => "nimda"
    })
    
    # Using block syntax
    Couch = CouchClient::Connection.new do |c| 
      c.scheme   = "http"
      c.host     = "localhost"
      c.port     = 5984
      c.database = "sandbox"
      c.username = "admin"
      c.password = "nimda"
    end
    
    # Using both hash and block syntax
    # NOTE: Hash parameters take precedence over block parameters
    Couch = CouchClient::Connection.new(:username => "admin", :password => "nidma") do |c| 
      c.scheme   = "http"
      c.host     = "localhost"
      c.port     = 5984
      c.database = "sandbox"
    end

Fetching a Document
-------------------
    
    # Using Hash syntax
    person = Couch["a3b556796203eab59c31fa21b00043e3"]
    
    # You can also pass options if desired
    person = Couch["a3b556796203eab59c31fa21b00043e3", :include_docs => true]

Getting a Document's id, rev and attachments
--------------------------------------------
    # A document's id
    person.id # => "a3b556796203eab59c31fa21b00043e3"

    # A document's rev
    person.rev # => "1-6665e6330ba75e757ce1f6d793305d67"

    # A document's attachments
    # NOTE: These will be CouchClient::Attachment objects
    person.attachments # => {"plain.txt"=>{"content_type"=>"text/plain", "revpos"=>2, "length"=>406, "stub"=>true}}
    
