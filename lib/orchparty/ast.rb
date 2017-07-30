require 'hashie'

module Orchparty
  class AST
    class Node < ::Hashie::Mash
      include Hashie::Extensions::DeepMerge
      include Hashie::Extensions::DeepMergeConcat
      include Hashie::Extensions::MethodAccess
      include Hashie::Extensions::Mash::KeepOriginalKeys
    end
  end
end
