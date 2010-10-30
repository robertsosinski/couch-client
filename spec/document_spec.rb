require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")
require 'digest/sha1'

describe CouchClient::Document do
  before(:each) do
    @couch = CouchClient.connect(COUCHDB_TEST_SETTINGS)
    @couch.database.create
    
    factory = lambda do |hash|
      doc = @couch.build(hash)
      doc.save
      doc
    end
    
    @alice   = factory.call({"name" => "alice", "city" => "nyc"})
    @bob     = factory.call({"name" => "bob", "city" => "chicago"})
    @new     = @couch.build
    @design  = factory.call({"_id" => "_design/people", "views" => {"all" => {"map" => "function(doc){emit(doc._id, doc)}"}}})
  end
  
  after(:each) do
    @couch.database.delete!
  end
  
  it 'should have #id, #rev and #attachments methods' do
    @alice.id.should eql(@alice["_id"])
    @alice.rev.should eql(@alice["_rev"])
    @alice.attachments.should eql(@alice["_attachments"])
  end
  
  it 'should have #id=, #rev= and #attachments= methods' do
    @alice.should respond_to(:id=)
    @alice.should respond_to(:rev=)
    @alice.should respond_to(:attachments=)
  end
  
  describe '#saved_doc' do
    it 'should get the doc from the database' do
      @alice["key"] = "value"
      @alice.saved_doc.should_not eql(@alice)
      
      @alice["key"].should eql("value")
      @alice.saved_doc["key"].should be_nil
    end
    
    it 'should return nothing if the doc is new' do
      lambda{@new.saved_doc}.should raise_error(CouchClient::DocumentNotAvailable)
    end
  end
  
  describe '#save' do
    it 'should save a new document' do
      @new.new?.should be_true
      @new.rev.should be_nil
      
      @new.save
      
      @new.new?.should be_false
      @new.rev.should_not be_nil
    end
    
    it 'should update an existing document' do
      @alice["key"].should be_nil
      @alice["key"] = "value"
      
      @alice.save
      
      @alice["key"].should eql("value")
      @alice.saved_doc["key"].should eql("value")
    end
    
    it 'should not save a document in conflict' do
      @alice_old = @alice.saved_doc
      @alice_old["old"] = true
      @alice["key"] = "value"
      
      @alice.save
      
      @alice_old.save
      @alice_old.error?.should be_true
      @alice_old.conflict?.should be_true
      @alice_old.error.should eql({"conflict"=>"Document update conflict."})
    end
  end
  
  describe '#attach' do
    before(:all) do
      @read = lambda do |file|
        File.read(File.join(File.dirname(__FILE__), "files", file))
      end
      
      @digest = lambda do |file|
        Digest::SHA1.hexdigest(file)
      end
      
      @plain = @read.call("plain.txt")
      @image = @read.call("image.png")
      
      @plain_digest = @digest.call(@plain)
      @image_digest = @digest.call(@image)
    end
    
    it 'should attach a file' do
      @alice.attach("plain.txt", @plain, "text/plain")
      @alice.attach("image.png", @image, "image/png")
      @alice = @alice.saved_doc
      
      @alice.attachments.should eql({"image.png"=>{"content_type"=>"image/png", "revpos"=>3, "length"=>104744, "stub"=>true}, "plain.txt"=>{"content_type"=>"text/plain", "revpos"=>2, "length"=>406, "stub"=>true}})
      @digest.call(@alice.attachments["plain.txt"].data).should eql(@plain_digest)
      @digest.call(@alice.attachments["image.png"].data).should eql(@image_digest)
    end
    
    it 'should not attach a file to a new record' do
      lambda{@new.attach("plain.txt", @plain, "text/plain")}.should raise_error(CouchClient::AttachmentError)
    end
  end
  
  describe '#delete!' do
    it 'should delete a docment' do
      @bob.deleted?.should be_false
      @bob.delete!
      @bob.deleted?.should be_true
      lambda{@bob.saved_doc}.should raise_error(CouchClient::DocumentNotFound)
    end
    
    it 'should not delete a document in conflict' do
      @alice_old = @alice.saved_doc
      @alice_old["old"] = true
      @alice["key"] = "value"
      
      @alice.save
      
      @alice_old.delete!
      @alice_old.error?.should be_true
      @alice_old.conflict?.should be_true
      @alice_old.error.should eql({"conflict"=>"Document update conflict."})
    end
  end
  
  describe '#design?' do
    it 'should identify a design document' do
      @design.design?.should be_true
    end
    
    it 'should not identify a normal document' do
      @alice.design?.should be_false
    end
  end
  
  describe '#new?' do
    it 'should identify a new document' do
      @alice.new?.should be_false
    end
    
    it 'should not identify an existing document' do
      @new.new?.should be_true
    end
  end

  describe '#error #error? and conflict?' do
    it 'should yield errors for a document that has errors' do
      @alice_old = @alice.saved_doc
      @alice["key"] = "value"
      
      @alice_old.error?.should be_false
      @alice_old.error.should eql({})
      @alice_old.conflict?.should be_false
      
      @alice.save
      @alice_old.save
      
      @alice_old.error?.should be_true
      @alice_old.error.should eql({"conflict"=>"Document update conflict."})
      @alice_old.conflict?.should be_true
    end
  end
  
  describe '#invalid?' do
    before(:each) do
      @alice.instance_variable_set(:@code, 403)
      @alice.instance_variable_set(:@error, {"forbidden" => "Document must have a name field."})
    end
    
    it 'should identify an invalid document' do
      @alice.invalid?.should be_true
    end
  end

  describe '#deleted?' do
    it 'should identify a deleted document' do
      @bob.deleted?.should be_false
      @bob.delete!
      @bob.deleted?.should be_true
    end
  end
end