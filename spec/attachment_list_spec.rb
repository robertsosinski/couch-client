require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::AttachmentList do
  it 'should exist inherent from ConsistentHash' do
    CouchClient::AttachmentList.ancestors[1].should eql(CouchClient::ConsistentHash)
  end
end