require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::AttachmentList do
  it 'should exist inherent from ConsistentHash' do
    CouchClient::AttachmentList.ancestors.should include(CouchClient::ConsistentHash)
  end
end