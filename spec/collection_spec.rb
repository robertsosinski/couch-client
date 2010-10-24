require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::Collection do
  before(:all) do
    @couch = CouchClient.connect(COUCHDB_TEST_SETTINGS)
    @couch.database.create
    
    factory = lambda do |hash|
      doc = @couch.build(hash)
      doc.save
      doc
    end
    
    @alice   = factory.call({"_id" => "123", "name" => "alice", "city" => "nyc"})
    @bob     = factory.call({"_id" => "456", "name" => "bob", "city" => "chicago"})
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
  
  it 'should be an CouchClient::Collection object' do
    @people.should be_a_kind_of(CouchClient::Collection)
  end
  
  it 'should have a collection of rows' do
    @people.size.should eql(2)
    @people.first["doc"].should eql(@alice)
    @people.last["doc"].should eql(@bob)
  end
  
  it 'should have `code` and `info` methods' do
    @people.should respond_to(:code)
    @people.should respond_to(:info)
  end
end