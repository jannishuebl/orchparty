require 'ostruct'
require 'orcparty/transformations/all'

module Orcparty
  module Transformations
    def self.transform(ast)
      ast = All.new.transform(ast)
    end
  end
end
