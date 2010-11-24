require 'digest/sha1'
require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::Attachment do
  before(:all) do
    @couch = CouchClient.connect(COUCHDB_TEST_SETTINGS)
    @couch.database.create
    
    @alice = @couch.build({"name" => "alice", "city" => "nyc"})
    @alice.save
    
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
    
    @alice.attach("plain.txt", @plain, "text/plain")
    @alice.attach("image.png", @image, "image/png")
    @alice.attach("missing", @plain, "text/plain") # will be deleted
    
    @alice = @alice.saved_doc
    
    @attachment_plain = @alice.attachments["plain.txt"]
    @attachment_image = @alice.attachments["image.png"]
    
    @attachment_missing = @alice.attachments["missing"]
    
    @alice.attachments.delete("missing")
    @alice.save
  end
  
  after(:all) do
    @couch.database.delete!
  end
  
  describe '#initialize' do
    it 'should typecast fields to the correct type' do
      attachment = CouchClient::Attachment.new("123abc", "text.txt", {"content_type" => "text/plain", "revpos" => "3", "length" => "123", "stub" => "true"}, true)
      attachment["content_type"].should eql("text/plain")
      attachment["revpos"].should eql(3)
      attachment["length"].should eql(123)
      attachment["stub"].should be_true
    end
  end
  
  describe '#uri' do
    it 'should yield the uri for the attachment' do
      @attachment_plain.uri.should eql([@couch.hookup.handler.uri, @alice.id, "plain.txt"].join("/"))
      @attachment_image.uri.should eql([@couch.hookup.handler.uri, @alice.id, "image.png"].join("/"))
    end
  end
  
  describe '#path' do
    it 'should yield the uri for the attachment' do
      @attachment_plain.path.should eql([@couch.hookup.handler.path, @alice.id, "plain.txt"].join("/"))
      @attachment_image.path.should eql([@couch.hookup.handler.path, @alice.id, "image.png"].join("/"))
    end
  end
  
  describe '#data' do
    it 'should yield the file for the attachment as a string' do
      @digest.call(@attachment_plain.data).should eql(@plain_digest)
      @digest.call(@attachment_image.data).should eql(@image_digest)
    end
    
    it 'should raise an error if the attachment is not found' do
      lambda{@attachment_missing.data}.should raise_error(CouchClient::AttachmentNotFound)
    end
  end
end