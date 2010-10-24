require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::Row do
  before(:all) do
    @couch = CouchClient.connect(COUCHDB_TEST_SETTINGS)
    @couch.database.create
    
    factory = lambda do |hash|
      doc = @couch.build(hash)
      doc.save
      doc
    end
    
    @alice   = factory.call({"_id" => "123", "name" => "alice", "city" => "nyc"})
    @design  = factory.call({"_id" => "_design/people", 
      "views" => {
        "all" => {"map" => "function(doc){emit(doc._id, doc)}"}
      }
    })
    
    @people = @couch.design("people").view("all", "include_docs" => true)
  end
  
  after(:all) do
    @couch.database.delete!
  end
  
  it 'should be an CouchClient::Row object' do
    @people.first.should be_a_kind_of(CouchClient::Row)
  end
  
  it 'should have a document as a CouchClient::Document object' do
    @people.first["doc"].should be_a_kind_of(CouchClient::Document)
  end
end