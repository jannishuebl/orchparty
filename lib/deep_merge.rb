module Hashie
  module Extensions
    module DeepMergeConcat

      def transform_values
        result = self.class.new
        each do |key, value|
          result[key] = yield(value)
        end
        result
      end

      def transform_values!
        each do |key, value|
          self[key] = yield(value)
        end
      end

      def transform_keys
        result = self.class.new
        each_key do |key|
          result[yield(key)] = self[key]
        end
        result
      end

      def transform_keys!
        keys.each do |key|
          self[yield(key)] = delete(key)
        end
        self
      end

      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      def deep_merge_concat(other_hash, &block)
        copy = dup
        copy.extend(Hashie::Extensions::DeepMergeConcat) unless copy.respond_to?(:deep_merge_concat!)
        copy.deep_merge_concat!(other_hash, &block)
      end

      # Returns a new hash with +self+ and +other_hash+ merged recursively.
      # Modifies the receiver in place.
      def deep_merge_concat!(other_hash, &block)
        return self unless other_hash.is_a?(::Hash)
        _recursive_merge_concat(self, other_hash, &block)
        self
      end

      def deep_transform_values(&block)
        _deep_transform_values_in_object(self, &block)
      end

      def deep_transform_values!(&block)
        _deep_transform_values_in_object!(self, &block)
      end

      private

      def _deep_transform_values_in_object(object, &block)
        case object
        when Hash
          object.each_with_object({}) do |arg, result|
            key = arg.first
            value = arg.last
            result[key] = _deep_transform_values_in_object(value, &block)
          end
        when Array
          object.map {|e| _deep_transform_values_in_object(e, &block) }
        else
          yield(object)
        end
      end

      def _deep_transform_values_in_object!(object, &block)
        case object
        when Hash
          object.each do |key, value|
            object[key] = _deep_transform_values_in_object!(value, &block)
          end
        when Array
          object.map! {|e| _deep_transform_values_in_object!(e, &block) }
        else
          yield(object)
        end
      end


      def _recursive_merge_concat(hash, other_hash, &block)
        other_hash.each do |k, v|
          hash[k] = if hash.key?(k) && hash[k].is_a?(::Hash) && v.is_a?(::Hash)
                      _recursive_merge(hash[k], v, &block)
                    elsif hash.key?(k) && hash[k].is_a?(::Array) && v.is_a?(::Array)
                      hash[k].concat(v)
                    else
                      if hash.key?(k) && block_given?
                        block.call(k, hash[k], v)
                      else
                        v.respond_to?(:deep_dup) ? v.deep_dup : v
                      end
                    end
        end
        hash
      end
    end
  end
end
