
module Orchparty
  module Transformations
    class Sort
      def transform(ast)
        AST::Node.new ast.deep_sort_by_key_and_sort_array(["command", "entrypoint"]) {|a, b| a.to_s <=> b.to_s }
      end
    end
  end
end
