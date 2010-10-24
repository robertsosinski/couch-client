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
    
    @attachment_plain = @alice.saved_doc.attachments["plain.txt"]
    @attachment_image = @alice.saved_doc.attachments["image.png"]
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
  
  describe '#file' do
    it 'should yield the file for the attachment as a string' do
      @digest.call(@attachment_plain.file).should eql(@plain_digest)
      @digest.call(@attachment_image.file).should eql(@image_digest)
    end
  end
end