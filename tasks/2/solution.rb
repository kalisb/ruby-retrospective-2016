class Hash
  def fetch_deep(path)
    path_elements = path.split('.')
    path_elements.reduce(self) do |hsh, key|
      hsh.stringify_keys[key] if hsh
    end
  end

  def reshape(shape)
    return fetch_deep(shape) if shape.is_a? String
    shape.map do |new_key, shape|
      [new_key, reshape(shape)]
    end.to_h
  end

  def stringify_keys
    map do |key, value|
      [key.to_s, value]
    end.to_h
  end
end
class Array
  def reshape(shape)
    map { |value| value.reshape(shape) }
  end

  def stringify_keys
    self.each_with_index.map do |value, index|
      [index.to_s, value]
    end.to_h
  end
end
