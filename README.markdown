Introduction
============

CouchClient is Ruby library that can be used to interact with CouchDB.  The goal of CouchClient is to make documents feel as much as possible as what they already represent, a Hash of primitives, Arrays and other Hashes.  As such, the interface for documents closely represents that of Hash and Array, but also includes additional methods and state in order to manage documents and interface with the CouchDB Server.

Installation
------------

    gem install couch-client
    
    # In your ruby application
    require 'couch-client'

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
    person = Couch["a3b556796203eab59c31fa21b00043e3", :attachments => true]

Getting a Document's id, rev and attachments
--------------------------------------------
    # A document's id
    person.id # => "a3b556796203eab59c31fa21b00043e3"

    # A document's rev
    person.rev # => "1-6665e6330ba75e757ce1f6d793305d67"

    # A document's attachments
    # NOTE: This will be a CouchClient::AttachmentList, and attachments will be CouchClient::Attachment objects
    person.attachments # => {"plain.txt"=>{"content_type"=>"text/plain", "revpos"=>2, "length"=>406, "stub"=>true}}
    

Working with a Document
-----------------------

    # Building new documents
    # Couch.build({:name => "alice"})

    # Getting and setting fields (with indifferent access and value "stringification")
    # person[:name] # => "alice"
    # person[:city] = :nyc
    # person["city"] # => "nyc"

    # Fetching the same document on the server
    person.saved_doc # => {"_id" => "7f22af967b04d1b88212d3d26b017ff6", "_rev" => "1-f867d6b9aa0a5c31d647d57110fa7d36", "name" => "alice"}

    # Saving a document
    person.save # => true
    person.rev # => "2-1734c07abaf18db573706bc1db59e09d"

    # Deleting a field
    person.delete(:city) # => true
    person[:city] # => nil

    # Attaching a file (documents must be refreshed for attachments to be available)
    person.attach("plain.txt", "Hello World", "plain/text") # => true
    person = person.saved_doc
    person.attachments # => {"plain.txt"=>{"content_type"=>"text/plain", "revpos"=>2, "length"=>406, "stub"=>true}}

    # Getting attached files
    attachment = person.attachments["plain.txt"]
    attachment.uri # => http://localhost:5984/sandbox/7f22af967b04d1b88212d3d26b017ff6/plain.txt
    attachment.path # => /sandbox/7f22af967b04d1b88212d3d26b017ff6/plain.txt
    attachment.data # => "Hello World"

    # Deleting a document
    person.delete!
    person.deleted? # => true

    # Identifying a design document
    person.design? # => false
    c["_design/people"].design? # => true

    # Identifying errors and conflicts
    person.error # => {"conflict"=>"Document update conflict."}
    person.error? # => true
    person.conflict? # => true
    person.invalid? # => false

Working with Collections
------------------------

    # Getting all documents
    Couch.all_docs # => [{"id"=>"7f22af967b04d1b88212d3d26b017ff6", "key"=>"7f22af967b04d1b88212d3d26b017ff6", "value"=>{"rev"=>"1-f867d6b9aa0a5c31d647d57110fa7d36"}},
                   #     {"id"=>"7f22af967b04d1b88212d3d26b018e89", "key"=>"7f22af967b04d1b88212d3d26b018e89", "value"=>{"rev"=>"3-3a635c1a2b5a8ff94bb5d63eee3cd6ef"}}]
    
    # Getting all documents with document fields
    Couch.all_docs(:include_docs => true)

    # Specifying a `key`, `start_key` or `end_key`
    couch.all_docs(:key => "7f22af967b04d1b88212d3d26b018e89")
    couch.all_docs(:start_key => 200)
    couch.all_docs(:end_key => [2010, 01, 01])

    # Getting additional collection information
    Couch.all_docs.info # => {"total_rows" => 2, "offset" => 0}

Using Design Documents
----------------------

    # Map Views
    Couch.design(:people).view(:all) # => [{"id"=>"7f22af967b04d1b88212d3d26b017ff6", "key"=>"7f22af967b04d1b88212d3d26b017ff6", "value"=>{"name" => "alice"}},
                                     #     {"id"=>"7f22af967b04d1b88212d3d26b018e89", "key"=>"7f22af967b04d1b88212d3d26b018e89", "value"=>{"name" => "bob"}}]

    # MapReduce Views
    Couch.design(:people).view(:sum) # => [{"key" => "male", "value" => 1}, {"key" => "female", "value" => 1}]

Using FullText Search (Must Have CouchDB-Lucene Installed)
----------------------------------------------------------

    # Getting search results
    Couch.design(:people).fulltext(:by_name, :q => "alice") # => [{"id"=>"a6c92090bbee241e892be1ac4464b9d9", "score"=>4.505526065826416, "fields"=>{"default"=>"alice"}}]

    # Getting additional search results information
    Couch.design(:people).fulltext(:by_name, :q => "alice").info # => {"q"=>"default:alice", "etag"=>"11e1541e20d9b860", "skip"=>0, "limit"=>25, 
                                                                 #     "total_rows"=>7, "search_duration"=>0, "fetch_duration"=>1}

    # Getting search index information
    Couch.design(:people).fulltext(:by_name) # => {"current"=>true, "disk_size"=>3759, "doc_count"=>25, "doc_del_count"=>3, "fields"=>["default"], 
                                             #     "last_modified"=>"1288403429000", "optimized"=>false, "ref_count"=>2}

Database Administration
-----------------------

    # Create a database
    Couch.database.create

    # See if a database exists
    Couch.database.exists?

    # Get database stats
    Couch.database.stats

    # Compact the database
    Couch.database.compact!

    # Delete the database
    Couch.databse.delete!



