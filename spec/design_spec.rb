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
    
    @alice   = factory.call({"_id" => "123", "name" => "alice", "city" => "nyc"})
    @bob     = factory.call({"_id" => "456", "name" => "bob", "city" => "chicago"})
    @charlie = factory.call({"_id" => "789", "name" => "charlie", "city" => "san fran"})
    @design  = factory.call({"_id" => "_design/people", 
      "views" => {
        "all" => {"map" => "function(doc){emit(doc._id, doc)}"},
        "sum" => {"map" => "function(doc){emit(null, 1)}", "reduce" => "function(id, values, rereduce){return sum(values)}"},
      },
      "shows" => {
        "html" => "function(doc, req){return{body: '<h1>' + doc.name + '</h1>', headers: {'Content-Type': 'text/html'}}}",
        "json" => "function(doc, req){return{body: JSON.stringify({'name': doc.name}), headers: {'Content-Type': 'application/json'}}}"
      },
      "lists" => {
        "json" => "function(head, req){var row;var rows = [];while(row = getRow()){rows.push(row.value.name);}send(JSON.stringify(rows));}"
      },
      "fulltext" => {
        "by_name" => {
          "index" => "function(doc){var ret = new Document();ret.add(doc.name);return ret;}"
        }
      }
    })
    
    @people = @couch.design("people")
  end
  
  after(:all) do
    @couch.database.delete!
  end
  
  it 'should have an id' do
    @people.id.should eql("people")
  end
  
  describe '#view' do
    it 'should return a mapped collection if the view exists' do
      view = @people.view("all", "include_docs" => true)
      view.should be_a(CouchClient::Collection)
      view.info.should be_a(Hash)
      view.size.should eql(3)
      view.first.keys.should eql(["id", "key", "value", "doc"])
      view.first["id"].should eql(@alice.id)
      view.last["id"].should eql(@charlie.id)
    end
    
    it 'should return mapped results based on "key"' do
      view = @people.view("all", "key" => @bob.id)
      view.size.should eql(1)
      view.first["id"].should eql(@bob.id)
    end
    
    it 'should return mapped results based on "startkey"' do
      view = @people.view("all", "startkey" => @bob.id)
      view.size.should eql(2)
      view.first["id"].should eql(@bob.id)
      view.last["id"].should eql(@charlie.id)
    end
    
    it 'should return mapped results based on "endkey"' do
      view = @people.view("all", "endkey" => @bob.id)
      view.size.should eql(2)
      view.first["id"].should eql(@alice.id)
    end
    
    it 'should return a mapped and reduced collection if the view exists' do
      view = @people.view("sum", "group" => true)
      view.should be_a(CouchClient::Collection)
      view.info.should be_a(Hash)
      view.size.should eql(1)
      view.first.keys.should eql(["key", "value"])
      view.first["value"].should eql(3)
    end
  end
  
  describe '#show' do
    it 'should return valid html for a html show function' do
      @people.show("html", "123").should eql("<h1>alice</h1>")
    end
    
    it 'should return valid json for a json show function' do
      @people.show("json", "123").should eql({"name"=>"alice"})
    end
  end
  
  describe '#list' do
    it 'should return valid json for a json list function' do
      @people.list("json", "people", "all").should eql(["alice", "bob", "charlie"])
    end
  end
  
  describe '#fulltext' do
    it 'should return a lucine status hash if the fulltext exists' do
      @people.fulltext("by_name").should be_a(Hash)
    end
    
    it 'should return a search results collection if the fulltext exists and a query is given' do
      fulltext = @people.fulltext("by_name", "q" => "al*")
      fulltext.should be_a(CouchClient::Collection)
      fulltext.info.should be_a(Hash)
      fulltext.first["id"].should eql(@alice.id)
    end
    
    it 'should return true when administration operations are successfully performed' do
      @people.fulltext("by_name", "optimize").should be_true
    end
    
    it 'should raise a "not found" error if the fulltext field was not found' do
      lambda{@people.fulltext("not_found")}.should raise_error(CouchClient::FullTextNotFound)
    end
    
    it 'should raise a "bad request" error if the requested administration operation was not valid' do
      lambda{@people.fulltext("by_name", "bad_request")}.should raise_error(CouchClient::FullTextRequestBad)
    end
  end
end