require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::ConnectionHandler do
  before(:all) do
    @ch = CouchClient::ConnectionHandler.new
  end
  
  it 'should have sensible defaults' do
    @ch.scheme.should eql("http")
    @ch.host.should eql("localhost")
    @ch.port.should eql(5984)
  end
  
  it 'should set parameters' do
    @ch.scheme = "https"
    @ch.username = "admin"
    @ch.password = "nimda"
    @ch.host = "couchone.com"
    @ch.port = 8080
    @ch.database = "sandbox"
  end
  
  it 'should get parameters' do
    @ch.scheme.should eql("https")
    @ch.username.should eql("admin")
    @ch.password.should eql("nimda")
    @ch.host.should eql("couchone.com")
    @ch.port.should eql(8080)
    @ch.database.should eql("sandbox")
  end
  
  it 'shoudl output a path string' do
    @ch.path.should eql("/sandbox")
  end
  
  it 'should output a uri string' do
    @ch.uri.should eql("https://couchone.com:8080/sandbox")
  end
  
  it 'should output a uri string with a path if passed a path' do
    @ch.uri("path").should eql("https://couchone.com:8080/sandbox/path")
    @ch.uri("path", {}).should eql("https://couchone.com:8080/sandbox/path")
    @ch.uri("_$,+-/").should eql("https://couchone.com:8080/sandbox/_%24%2C%2B-/")
    @ch.uri("?=&; #").should eql("https://couchone.com:8080/sandbox/%3F%3D%26%3B+%23")
  end
  
  it 'shoudl output a uri string wiht a path if the path is passed as an array with special characters' do
    @ch.uri(["_d*s!gn", "spaces & special/chars"]).should eql("https://couchone.com:8080/sandbox/_d%2As%21gn/spaces+%26+special%2Fchars")
  end
  
  it 'should output a uri string with a query if a query is given' do
    @ch.uri(nil, {"a" => "apple"}).should eql("https://couchone.com:8080/sandbox?a=apple")
    @ch.uri(nil, {"a" => "apple", "b" => "banana"}).should eql("https://couchone.com:8080/sandbox?a=apple&b=banana")
    @ch.uri(nil, {"a" => "_$,+-/", "b" => "?=&; #"}).should eql("https://couchone.com:8080/sandbox?a=_%24%2C%2B-%2F&b=%3F%3D%26%3B+%23")
  end
  
  it 'should output a uri string with path and query if both are given' do
    @ch.uri("path", {"a" => "apple", "b" => "banana"}).should eql("https://couchone.com:8080/sandbox/path?a=apple&b=banana")
  end
end