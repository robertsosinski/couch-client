module CouchClient
  # ConsistentHash allows indifferent access with either with symbols or strings
  # while also converting symbol values in Arrays or Hashes into strings values.
  #
  # This code was is heavily influenced by ActiveSupport::HashWithIndifferentAccess.
  class ConsistentHash < Hash
    def initialize(constructor = {})
      if constructor.is_a?(Hash)
        super
        update(constructor)
      else
        super(constructor)
      end
    end

    def default(key = nil)
      if key.is_a?(Symbol) && include?(key = key.to_s)
        self[key]
      else
        super
      end
    end

    def self.new_from_hash_copying_default(hash)
      ConsistentHash.new(hash).tap do |new_hash|
        new_hash.default = hash.default
      end
    end

    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    def []=(key, value)
      regular_writer(convert_key(key), convert_value(value))
    end

    def update(other_hash)
      other_hash.each_pair do |key, value| 
        regular_writer(convert_key(key), convert_value(value))
      end
      self
    end

    alias_method :merge!, :update

    def key?(key)
      super(convert_key(key))
    end

    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?

    def fetch(key, *extras)
      super(convert_key(key), *extras)
    end

    def values_at(*indices)
      indices.collect {|key| self[convert_key(key)]}
    end

    def dup
      ConsistentHash.new(self)
    end

    def merge(hash)
      dup.update(hash)
    end

    def delete(key)
      super(convert_key(key))
    end

    def to_hash
      Hash.new(default).merge!(self)
    end

    protected

    def convert_key(key)
      key.is_a?(Symbol) ? key.to_s : key
    end

    def convert_value(value)
      if value.instance_of?(Hash)
        self.class.new_from_hash_copying_default(value)
      elsif value.instance_of?(Symbol)
        value.to_s
      elsif value.instance_of?(Array)
        value.collect{|e| convert_value(e)}
      else
        value
      end
    end
  end
end