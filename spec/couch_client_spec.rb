require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient do
  it 'should exist' do
    CouchClient.should be_a(Module)
  end
  
  it 'should have a .connect method that constructs a new CouchClient::Connection object' do
    CouchClient.connect(:database => "sandbox").should be_a(CouchClient::Connection)
  end
end
