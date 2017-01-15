module DataModelBasic
  def attributes(*attributes)
    return @attributes if attributes.empty?
    
    @attributes = attributes
    attributes.each do |value|
      attr_accessor(value)
      define_singleton_method("find_by_#{value}") do |arg|
        query = {value => arg}
        where(query)
      end
    end
  end

  def data_store(store = {})
    @store = store unless @store
    @store
  end

  def where(hsh)
    hsh.each do |key, _|
      unless (@attributes.include? key) || (key == :id)
        raise DataModel::UnknownAttributeError.new(key)
      end
    end
    @store.find(hsh).map do |value|
      self.new(value)
    end
  end
end
class DataModel
  extend DataModelBasic

  attr_accessor :id

  class UnknownAttributeError < ArgumentError
    def initialize(attribute_name)
      super "Unknown attribute #{attribute_name}"
    end
  end

  class DeleteUnsavedRecordError < StandardError
  end

  def initialize(values = {})
    values.map do |key, _| 
      self.public_send("#{key}=", values[key]) if self.respond_to? "#{key}="
    end
  end

  def save
    store.create(convert)
    self
  end
  
  def delete
    raise DataModel::DeleteUnsavedRecordError unless id
    store.delete(convert)
    self
  end

  def ==(other)
    return id == other.id if id && other.id
    equal? other
  end

  def convert
    hsh = {} 
    store.counter = counter + 1 unless @id
    @id = counter unless @id
    hsh[:id] = self.id
    self.class.instance_variable_get('@attributes').each do |var| 
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
    to_delete = find(hash)
    to_delete.each { |hash| @storage[hash[:id]] = nil }
  end
end
class HashStore
  include Store

  def initialize
    @storage = {}
    @counter = 0
  end

  def find(hash)
    @storage.values.select do |elem|
      elem if matches(hash, elem)
    end
  end

  private
    def matches(hash, elem)
      true if hash.empty?
      hash.all? { |key, value| elem[key] == value }
    end
end
class ArrayStore
  include Store
  
  def initialize
    @storage = []
    @counter = 0
  end

  def find(hash)
    @storage.select do |elem|
      elem if elem && matches(hash, elem)
    end
  end

  private
    def matches(hash, elem)
      true if hash.empty?
      hash.all? { |key, value| elem[key] == value }
    end
end
