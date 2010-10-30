require File.join(File.dirname(File.expand_path(__FILE__)), "spec_helper")

describe CouchClient::ConsistentHash do
  describe '#initialize' do
    describe 'when given a hash' do
      before do
        @ch = CouchClient::ConsistentHash.new({:a => "apple", "b" => :banana})
      end
      
      it 'should construct a new ConsistentHash' do
        @ch[:a].should eql("apple")
        @ch["a"].should eql("apple")
        @ch[:b].should eql("banana")
        @ch["b"].should eql("banana")
        @ch[:c].should be_nil
      end
    end

    describe 'when given a default value' do
      before do
        @ch = CouchClient::ConsistentHash.new("default")
        @ch[:a] = "apple"
      end
      
      it 'should construct a new ConsistentHash with a default' do
        
        @ch[:a].should eql("apple")
        @ch[:b].should eql("default")
      end
    end
    
    describe 'when given a hash with a default value' do
      before do
        h = Hash.new("default")
        h[:a] = "apple"
        @ch = CouchClient::ConsistentHash.new(h)
        @ch[:b] = "banana"
      end
      
      it 'should construct a new ConsistentHash with a default' do
        @ch[:a].should eql("apple")
        @ch[:b].should eql("banana")
        @ch[:z].should eql("default")
      end
    end
  end

  describe '#default' do
    before do
      @ch = CouchClient::ConsistentHash.new("default")
      @ch[:a] = "apple"
    end
    
    it 'should give the default value if it does not exists' do
      @ch.default.should eql("default")
    end
  end

  describe '#[]=' do
    before do
      @ch = CouchClient::ConsistentHash.new()
    end
    
    it 'should set a field' do
      @ch[:a] = "apple"
      @ch[:a].should eql("apple")
      @ch["a"].should eql("apple")
    end
  end

  describe '#update, #merge!' do
    before do
      @ch = CouchClient::ConsistentHash.new({:a => "apple", :b => "banana"})
    end
    
    it 'should update an existing hash with fields from a new hash' do
      @ch.update({:b => "blueberry", :c => "cherry"})
      @ch.should eql({"a"=>"apple", "b"=>"blueberry", "c"=>"cherry"})
    end
  end

  describe '#key?' do
    before do
      @ch = CouchClient::ConsistentHash.new({:a => "apple"})
    end
    
    it 'should identify if a hash has a key' do
      @ch.key?(:a).should be_true
      @ch.key?(:b).should be_false
    end
  end

  describe '#fetch' do
    before do
      @ch = CouchClient::ConsistentHash.new({:a => "apple"})
    end
    
    it 'should return the value if the key given exists' do
      @ch.fetch(:a).should eql("apple")
    end
    
    it 'should raise an error if the key given does not exist' do
      lambda{@ch.fetch(:b)}.should raise_error(KeyError)
    end
    
    it 'should return a default if one is given' do
      @ch.fetch(:b, "default").should eql("default")
    end
  end

  describe '#values_at' do
   before do
      @ch = CouchClient::ConsistentHash.new({:a => "apple", :b => "banana", :c => "cherry"})
    end
    
    it 'should return an array of values for the keys given' do
      @ch.values_at(:a, :c).should eql(["apple", "cherry"])
    end
  end

  describe '#dup' do
    before do
      @ch = CouchClient::ConsistentHash.new({:a => "apple"})
    end
    
    it 'should return a new hash' do
      @ch2 = @ch.dup
      @ch2.object_id.should_not eql(@ch.object_id)
    end
  end
  
  describe '#merge' do
    before do
      @ch = CouchClient::ConsistentHash.new({:a => "apple", :b => "banana"})
    end
    
    it 'should return an new hash with fields from both hashs' do
      @ch2 = @ch.merge({:b => "blueberry", :c => "cherry"})
      
      @ch.should eql({"a" => "apple", "b" => "banana"})
      @ch2.should eql({"a"=>"apple", "b"=>"blueberry", "c"=>"cherry"})
    end
  end

  describe '#delete' do
    before do
      @ch = CouchClient::ConsistentHash.new({:a => "apple"})
    end
    
    it 'should delete the specified field' do
      @ch.delete(:b)
      @ch.should eql({"a" => "apple"})
    end
  end

  describe '#to_hash' do
    before do
      @ch = CouchClient::ConsistentHash.new({:a => "apple"})
    end
    
    it 'should return a regular hash' do
      @h = @ch.to_hash
      
      @ch[:a].should eql("apple")
      @h[:a].should be_nil
      
      @ch.should be_an_instance_of(CouchClient::ConsistentHash)
      @h.should be_an_instance_of(Hash)
    end
  end
end
