require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")
require 'digest/sha1'

describe CouchClient::Hookup do
  before(:all) do
    handler = CouchClient::ConnectionHandler.new
    handler.database = COUCHDB_TEST_DATABASE
    
    @hookup = CouchClient::Hookup.new(handler)
  end
  
  after(:all) do
    @hookup.delete
  end
  
  describe 'rest methods' do
    describe 'put' do
      it 'should create a database if one does not exist' do
        @hookup.put.should eql([201, {"ok" => true}])
      end

      it 'should not create a database if one already exists' do
        @hookup.put.should eql([412, {"error" => "file_exists", "reason" => "The database could not be created, the file already exists."}])
      end

      it 'should create a document if a path is provided' do
        @hookup.put(["alice"]).should eql([201, {"ok" => true, "id" => "alice", "rev" => "1-967a00dff5e02add41819138abb3284d"}])
      end

      it 'should create a document with fields if a path with data is provided' do
        @hookup.put(["bob"], {}, {"name" => "bob", "city" => "nyc"}).should eql([201, {"ok" => true, "id" => "bob", "rev" => "1-fb4ceea745e7c1cd487886f06eba6536"}])
      end
    end
    
    describe 'post' do
      before(:all) do
        @hookup.put
      end
      
      it 'should create a document' do
        code, body = @hookup.post(nil, {}, {"name" => "charlie"})
        code.should eql(201)
        body.should be_a(Hash)
      end
    end
    
    describe 'get and head' do
      before(:all) do
        @hookup.put
        @hookup.put(["dave"], {}, {"name" => "dave", "city" => "chicago"})
        @id = @hookup.post(nil, {}, {"name" => "edgar", "city" => "miami"}).last["id"]
      end
      
      it 'should get database information when not given a path' do
        code, body = @hookup.get
        code.should eql(200)
        body["db_name"].should eql("couch-client_test")
      end
      
      it 'should get a document when given a path' do
        @hookup.get(["dave"]).should eql([200, {"_id" => "dave", "_rev" => "1-17a22c4b658fd637577a4626344be252", "name" => "dave", "city" => "chicago"}])
        code, body = @hookup.get([@id])
        code.should eql(200)
        body["name"].should eql("edgar")
        body["city"].should eql("miami")
      end
      
      it 'should head a document when given a path' do
        @hookup.head(["dave"]).should eql([200, nil])
        code, body = @hookup.head([@id])
        code.should eql(200)
        body.should be_nil
      end
    end
    
    describe 'delete' do
      before(:all) do
        @hookup.put
        @rev = @hookup.put(["fred"], {}, {"name" => "fred", "city" => "san fran"}).last["rev"]
      end
      
      it 'should delete a document when given a path' do
        @hookup.delete(["fred"], {"rev" => @rev}).should eql([200, {"ok" => true, "id" => "fred", "rev" => "2-9bee1aef2fee82160ae8549079645933"}])
      end
      
      it 'should delete the database when not given a path' do
        @hookup.delete.should eql([200, {"ok" => true}])
      end
    end
  end
  
  describe 'attachments' do
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
      
      @hookup.put
      @rev = @hookup.put(["greg"], {}, {"name" => "greg", "city" => "austin"}).last["rev"]
    end
    
    it 'can be uploaded' do
      @rev = @hookup.put(["greg", "plain.txt"], {"rev" => @rev}, @plain, "text/plain").last["rev"]
      @rev = @hookup.put(["greg", "image.png"], {"rev" => @rev}, @image, "image/png").last["rev"]
    end
    
    it 'can be downloaded' do
      @digest.call(@hookup.get(["greg", "plain.txt"], {}, "text/plain").last).should eql(@plain_digest)
      @digest.call(@hookup.get(["greg", "image.png"], {}, "image/png").last).should eql(@image_digest)
    end
  end
end