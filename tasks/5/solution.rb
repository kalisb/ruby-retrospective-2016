module DataModelBasic
  def save
    store.create(self.convert)
    self
  end
  
  def delete
    raise DeleteUnsavedRecordError unless id
    store.delete(self.convert)
    self
  end

  def ==(other_object)
    return false if self.class != other_object.class 
    return true if self.id == other_object.id
    self.object_id == other_object.object_id
  end

  def convert
    hsh = {} 
    store.counter = counter + 1 unless @id
    @id = counter unless @id
    hsh[:id] = self.id
    attributes.each do |var| 
      value = instance_variable_get "@#{var}"       
      hsh[var.to_sym] = value
    end
    hsh
  end

  def counter 
    self.class.instance_variable_get('@store').counter
  end

  def store
    self.class.instance_variable_get('@store')
  end

  def attributes
    self.class.instance_variable_get('@attributes')
  end
end
class DataModel
  include DataModelBasic
  attr_accessor :id
  def initialize(values = {})
    values.map do |key, _| 
      self.public_send("#{key}=", values[key]) if self.respond_to? "#{key}="
    end
  end

  class << self
    def attributes(*attributes)
      @attributes = attributes
      attributes.each do |value|
        attr_accessor(value)
        self.define_singleton_method("find_by_#{value}") do |arg|
          query = {value => arg}
          @store.find(query)
        end
      end
    end

    def data_store(store = {})
      @store = store unless @store
      @store
    end

    def where(hsh)
      @store.find(hsh).map do |value|
        self.new(value)
      end.to_a
    end
  end
end
module Store
  attr_accessor :counter

  def create(hash)
    @storage[hash[:id]] = hash
  end

  def find(hash)
  end

  def update(id, hash)
    @storage[id] = hash
  end 

  def delete(hash)
    @storage[hash[:id]] = nil
  end
end
class HashStore
  include Store

  def initialize
    @storage = {}
    @counter = 0
  end

  def find(hash)
    result = []
    @storage.select do |_, elem|
      hash.each do |key, value|
        result << elem if elem && elem[key] == value
      end
    end
    result
  end
end
class ArrayStore
  include Store
  
  def initialize
    @storage = []
    @counter = 0
  end

  def find(hash)
    result = []
    @storage.each do |elem|
      hash.each do |key, value|
        result << elem if elem && elem[key] == value && !(result.include? elem)
      end
    end
    result
  end
end
class DeleteUnsavedRecordError < StandardError
end
