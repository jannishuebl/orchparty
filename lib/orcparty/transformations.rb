require 'ostruct'
require 'orcparty/transformations/all'
require 'orcparty/transformations/variable'
require 'orcparty/transformations/mixin'
require 'orcparty/transformations/remove_internal'

module Orcparty
  module Transformations
    def self.transform(ast)
      ast = Mixin.new.transform(ast)
      ast = All.new.transform(ast)
      ast = RemoveInternal.new.transform(ast)
    end
  end
end
