require 'ostruct'
require 'orchparty/transformations/all'
require 'orchparty/transformations/variable'
require 'orchparty/transformations/mixin'
require 'orchparty/transformations/remove_internal'

module Orchparty
  module Transformations
    def self.transform(ast)
      ast = All.new.transform(ast)
      ast = Mixin.new.transform(ast)
      ast = Variable.new.transform(ast)
      ast = RemoveInternal.new.transform(ast)
    end
  end
end
