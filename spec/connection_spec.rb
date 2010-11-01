require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::Connection do
  before(:all) do
    @couch = CouchClient.connect(COUCHDB_TEST_SETTINGS)
    @couch.database.create
    
    factory = lambda do |hash|
      doc = @couch.build(hash)
      doc.save
      doc
    end
    
    @alice   = factory.call({"name" => "alice", "city" => "nyc"})
    @bob     = factory.call({"name" => "bob", "city" => "chicago"})
    @deleted = factory.call({"name" => "deleted", "city" => "unknown"})
    @deleted.delete! # used to test if deleted documents raise an error when fetched
    @design  = factory.call({"_id" => "_design/people", "views" => {"all" => {"map" => "function(doc){emit(doc._id, doc)}"}}})
  end
  
  after(:all) do
    @couch.database.delete!
  end
  
  it 'should have a Hookup' do
    @couch.hookup.should be_a(CouchClient::Hookup)
  end
  
  it 'should have a Database' do
    @couch.database.should be_a(CouchClient::Database)
  end
  
  describe '#[]' do
    it 'should get the document associated if it exists' do
      @couch[@alice["_id"]].should eql(@alice)
      @couch[@bob["_id"]].should eql(@bob)
      @couch[@design["_id"]].should eql(@design)
    end
    
    it 'should raise an error if the document was deleted' do
      lambda{@couch[@deleted["_id"]].should}.should raise_error(CouchClient::DocumentNotFound)
    end
    
    it 'should raise an error if the document does not exist' do
      lambda{@couch['missing'].should}.should raise_error(CouchClient::DocumentNotFound)
    end
    
    it 'should raise an error if the response was not a valid document' do
      lambda{@couch["_design/people/_view/all"]}.should raise_error(CouchClient::DocumentNotValid)
    end
  end
  
  describe '#design' do
    it 'should return a design object when a valid design id is given' do
       @couch.design("people").should be_a(CouchClient::Design)
    end
    
    it 'should allow access to design views' do
      @couch.design("people").view("all").should be_a(CouchClient::Collection)
    end
  end
  
  describe '#all_docs' do
    it 'should return a list of all documents stored' do
      all_docs = @couch.all_docs("include_docs" => true)
      all_docs.should be_a(CouchClient::Collection)
      docs = all_docs.map{|doc| doc["doc"].id}
      docs.should include(@alice.id)
      docs.should include(@bob.id)
      docs.should include(@design.id)
    end
  end
  
  describe '#all_design_docs' do
    it 'should return a list of all documents stored' do
      all_docs = @couch.all_design_docs("include_docs" => true)
      all_docs.should be_a(CouchClient::Collection)
      docs = all_docs.map{|doc| doc["doc"].id}
      docs.should_not include(@alice.id)
      docs.should_not include(@bob.id)
      docs.should include(@design.id)
    end
  end
  
  describe '#build' do
    before(:all) do
      @charlie = @couch.build({"name" => "charlie", "city" => "san fran"})
    end
    
    it 'should create a new Document' do
      @charlie.should be_a(CouchClient::Document)
    end
    
    it 'should have the hash keys and values provided' do
      @charlie.should eql({"name" => "charlie", "city" => "san fran"})
    end
  end
  
  describe '#inspect' do
    it 'should yield an inspect string with valid settings' do
      @couch.inspect.should eql("#<CouchClient::Connection: uri: http://localhost:5984/couch-client_test>")
    end
  end
end
