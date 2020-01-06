require 'ostruct'
require 'orchparty/transformations/all'
require 'orchparty/transformations/variable'
require 'orchparty/transformations/mixin'
require 'orchparty/transformations/remove_internal'
require 'orchparty/transformations/sort'

module Orchparty
  module Transformations
    def self.transform(ast, opts = {})
      ast = Mixin.new.transform(ast)
      ast = All.new.transform(ast)
      ast = Variable.new(opts).transform(ast)
      ast = RemoveInternal.new.transform(ast)
      ast = Sort.new.transform(ast)
    end

    def self.transform_kubernetes(ast, opts = {})
      ast = All.new.transform(ast)
      ast = Mixin.new.transform(ast)
      ast = Variable.new(opts).transform(ast)
    end
  end
end
