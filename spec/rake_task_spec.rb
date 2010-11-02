require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::RakeTask do
  before(:all) do
    Couch = CouchClient.connect(COUCHDB_TEST_SETTINGS)
    
    @task = CouchClient::RakeTask.new do |t|
      t.connection  = Couch
      # t.design_path = "./spec/designs"
    end
  end
  
  describe '#sync' do
    before(:all) do
      Couch.database.create
    end
    
    after(:all) do
      Couch.database.delete!
    end
    
    it 'should create a new design document' do
      @task.design_path = Pathname("./spec/designs/create")
      
      lambda{Couch["_design/people"]}.should raise_error(CouchClient::DocumentNotFound)
      
      suppress{@task.sync}
      
      @doc = Couch["_design/people"]
      @doc.code.should eql(200)
      @rev = @doc.rev
      @rev[0].should eql("1")
    end
    
    it 'should update an existing design document' do
      @task.design_path = Pathname("./spec/designs/update")
      
      suppress{@task.sync}
      
      @doc = Couch["_design/people"]
      @doc.code.should eql(200)
      @doc.rev.should_not eql(@rev)
      @doc.rev[0].should eql("2")
    end
    
    it 'should delete a missing design document' do
      @task.design_path = Pathname("./spec/designs/delete")
      
      suppress{@task.sync}
      
      lambda{Couch["_design/people"]}.should raise_error(CouchClient::DocumentNotFound)
    end
  end
  
  describe '#create, #compact, #delete' do
    describe '#create' do
      it 'should create a new database' do
        Couch.database.exists?.should be_false
        suppress{@task.create}
        Couch.database.exists?.should be_true
      end
    end
    
    describe '#compact' do
      it 'should compact a database' do
        suppress{@task.compact}
      end
    end
    
    describe '#delete' do
      it 'should delete a database' do
        Couch.database.exists?.should be_true
        suppress{@task.delete}
        Couch.database.exists?.should be_false
      end
    end
  end
end
