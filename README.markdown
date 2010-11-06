Introduction
============

CouchClient is a Ruby interface for CouchDB that provides easy configuration, state management and utility methods.

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

    # Specifying a `key`, `startkey` or `endkey`
    couch.all_docs(:key => "7f22af967b04d1b88212d3d26b018e89")
    couch.all_docs(:startkey => 200)
    couch.all_docs(:endkey => [2010, 01, 01])

    # Getting additional collection information
    Couch.all_docs.info # => {"total_rows" => 2, "offset" => 0}

Using Design Documents
----------------------

    # Map Views
    Couch.design(:people).view(:all) # => [{"id"=>"7f22af967b04d1b88212d3d26b017ff6", "key"=>"7f22af967b04d1b88212d3d26b017ff6", "value"=>{"name" => "alice"}},
                                     #     {"id"=>"7f22af967b04d1b88212d3d26b018e89", "key"=>"7f22af967b04d1b88212d3d26b018e89", "value"=>{"name" => "bob"}}]

    # MapReduce Views
    Couch.design(:people).view(:sum) # => [{"key" => "male", "value" => 1}, {"key" => "female", "value" => 1}]

Using Show and List Functions
-----------------------------

    # Show Functions
    Couch.design(:people).show(:html) # => "<h1>alice</h1>"
    Couch.design(:people).show(:json) # => {"name" => "alice"}
    
    # List Functions
    Couch.design(:people).list(:json, :people, :all) # => ["alice", "bob", "charlie"]

Using FullText Search (Must Have CouchDB-Lucene Installed)
----------------------------------------------------------

    # Getting search results
    Couch.design(:people).fulltext(:by_name, :q => "ali*") # => [{"id"=>"a6c92090bbee241e892be1ac4464b9d9", "score"=>4.505526065826416, "fields"=>{"default"=>"alice"}}]

    # Getting additional search results information
    Couch.design(:people).fulltext(:by_name, :q => "ali*").info  # => {"q"=>"default:alice", "etag"=>"11e1541e20d9b860", "skip"=>0, "limit"=>25, 
                                                                 #     "total_rows"=>7, "search_duration"=>0, "fetch_duration"=>1}

    # Getting search index information
    Couch.design(:people).fulltext(:by_name) # => {"current"=>true, "disk_size"=>3759, "doc_count"=>25, "doc_del_count"=>3, "fields"=>["default"], 
                                             #     "last_modified"=>"1288403429000", "optimized"=>false, "ref_count"=>2}
    
    # Optimizing an index
    Couch.design(:people).fulltext(:by_name, :optimize) # => true
    
    # Expunging an index
    Couch.design(:people).fulltext(:by_name, :expunge) # => true

Convenience Rake Tasks
----------------------

CouchClient rake tasks can be enabled by adding the following to your `Rakefile`.

    CouchClient::RakeTask.new do |c|
      c.connection  = Couch
      c.design_path = "./designs"
    end

Two parameters are available, `connection` should be the actual variable used for your CouchDB interface and `design_path` should be the application's location where design documents will be stored.

Within the design path, you should format each design document with folders and files corresponding to the fields in your design document.

    designs
    ├── people
    │   ├── fulltext
    │   │   └── by_name
    │   │       └── index.js
    │   ├── lists
    │   │   ├── html.js
    │   │   └── json.js
    │   ├── shows
    │   │   ├── html.js
    │   │   ├── json.js
    │   │   └── xml.js
    │   ├── validate_on_update.js
    │   └── views
    │       ├── all
    │       │   └── map.js
    │       └── sum
    │           ├── map.js
    │           └── reduce.js
    └── robots
        ├── fulltext
        │   └── by_name
        │       └── index.js
        ├── validate_on_update.js
        └── views
            ├── all
            │   └── map.js
            └── sum
                ├── map.js
                └── reduce.js
    
Once you have your design documents created, you can rum `rake couch:sync`, and CouchClient will create new documents, update existing documents (only if there are changes) and delete documents that no longer exist.

CouchClient also offers tasks that help in maintaining CouchDB.
    
    # Create a database
    rake couch:create
    
    # Delete a database
    rake couch:delete
    
    # Compact a database
    rake couch:compact

Performing Database Administration
----------------------------------

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



