class HashUtils
  def self.transform_hash(original, options={}, &block)
    original.inject({}){|result, (key,value)|
      value = if (options[:deep] && Hash === value)
                transform_hash(value, options, &block)
              else
                if Array === value
                  value.map{|v|
                    if Hash === v
                      transform_hash(v, options, &block)
                    else
                      v
                    end}
                else
                  value
                end
              end
      block.call(result,key,value)
      result
    }
  end
  # Convert keys to strings, recursively
  def self.deep_stringify_keys(hash)
    transform_hash(hash, :deep => true) {|hash, key, value|
      hash[key.to_s] = value
    }
  end
end
