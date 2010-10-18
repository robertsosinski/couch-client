require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::Database do
  before(:all) do
    @couch = CouchClient.connect(COUCHDB_TEST_SETTINGS)
    @couch.database.create
  end
  
  after(:all) do
    @couch.database.delete!
  end
  
  
  describe '#stats' do
    it 'should exist' do
      @couch.database.stats.should be_a(Hash)
    end
  end
  
  describe '#exists?' do
    it 'should exist' do
      @couch.database.exists?.should be_a(TrueClass)
    end
  end
  
  describe '#create' do
    # Is already tested as it is used in the before(:all) setup 
    # to make the database that is currently being tested.
  end
  
  describe '#delete' do
    # Is already tested as it is used in the after(:all) teardown 
    # to delete the database that is currently being tested.
  end
  
  describe '#compact!' do
    it 'should exist' do
      @couch.database.compact!.should be_a(Hash)
    end
  end
  
  describe '#replicate' do
    pending 'will be built in another release'
  end
end