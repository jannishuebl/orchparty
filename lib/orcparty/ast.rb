require 'hashie'

module Orcparty
  class AST
    class Node < ::Hashie::Mash
      include Hashie::Extensions::DeepMerge
      include Hashie::Extensions::DeepMergeConcat
      include Hashie::Extensions::MethodAccess
      include Hashie::Extensions::Mash::KeepOriginalKeys
    end
  end
end
require 'orcparty/ast/application'
require 'orcparty/ast/mixin'
require 'orcparty/ast/root'
require 'orcparty/ast/service'
