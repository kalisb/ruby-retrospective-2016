class Hash
  def fetch_deep(path)
    path_elements = path.split('.')
    path_elements.reduce(self) do |hsh, key|
      if hsh
        hsh = hsh.stringify_keys
        hsh[key]
      end
    end
  end

  def reshape(shape)
    result = shape
    shape.each do |(key, value)|
      if value.is_a? Hash
        reshape(value)
      else
        result[key] = self.fetch_deep(value)
      end
    end
  end

  def stringify_keys
    result = {}
    each_key do |key|
      result[key.to_s] = self[key]
    end
    result
  end
end
class Array
  def reshape(shape)
    self.each_with_index do |value, index|
      self[index] = value.reshape(shape.dup)
    end
  end

  def stringify_keys
    result = self.each_with_index.map do |value, index|
      [index.to_s, value]
    end
    result.to_h
  end
end
