module HashAccessor
  def hash_accessor(hash_name, *key_names)
    key_names.each do |key_name|
      define_method key_name do
        instance_variable_get("@#{hash_name}")[key_name]
      end
      define_method "#{key_name}=" do |value|
        instance_variable_get("@#{hash_name}")[key_name] = value
      end
    end
  end
end