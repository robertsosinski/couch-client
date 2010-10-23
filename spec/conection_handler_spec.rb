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
    @ch.uri(["path"]).should eql("https://couchone.com:8080/sandbox/path")
    @ch.uri(["path"], nil).should eql("https://couchone.com:8080/sandbox/path")
    @ch.uri(["_$,+-/"]).should eql("https://couchone.com:8080/sandbox/_%24%2C%2B-%2F")
    @ch.uri(["?=&; #"]).should eql("https://couchone.com:8080/sandbox/%3F%3D%26%3B+%23")
    @ch.uri(["_design/test", "spaces & special/chars"]).should eql("https://couchone.com:8080/sandbox/_design/test/spaces+%26+special%2Fchars")
  end
  
  it 'should output a uri string with a query if a query is given' do
    @ch.uri(nil, {"a" => "apple"}).should eql("https://couchone.com:8080/sandbox?a=apple")
    @ch.uri(nil, {"a" => "apple", "b" => "banana"}).should eql("https://couchone.com:8080/sandbox?a=apple&b=banana")
    @ch.uri(nil, {"a" => "_$,+-/", "b" => "?=&; #"}).should eql("https://couchone.com:8080/sandbox?a=_%24%2C%2B-%2F&b=%3F%3D%26%3B+%23")
  end
  
  it 'should output a uri string with path and query if both are given' do
    @ch.uri(["path", "one", "two"], {"a" => "apple", "b" => "banana"}).should eql("https://couchone.com:8080/sandbox/path/one/two?a=apple&b=banana")
  end
  
  it 'should properly escape database urls' do
    @ch.database = "abc123/_$()+-"
    @ch.uri(["path"]).should eql("https://couchone.com:8080/abc123%2F_%24%28%29%2B-/path")
  end
  
  it 'should raise an error if an invalid name is given' do
    lambda{@ch.database = "ABC!@#"}.should raise_error(CouchClient::InvalidDatabaseName)
  end
end