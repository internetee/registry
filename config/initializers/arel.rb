require 'arel/nodes/binary'
require 'arel/predications'
require 'arel/visitors/postgresql'

module Arel
  class Nodes::ContainsArray < Arel::Nodes::Binary
    def operator
      :"@>"
    end
  end

  class Visitors::PostgreSQL
    private

    def visit_Arel_Nodes_ContainsArray(o, collector)
      infix_value o, collector, ' @> '
    end
  end

  module Predications
    def contains_array(other)
      Nodes::ContainsArray.new self, Nodes.build_quoted(other, self)
    end
  end
end