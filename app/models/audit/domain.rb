module Audit
  class Domain < Base
    self.table_name = 'audit.domains'

    # ransacker :link_type do |parent|
    #   Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
    #                                   Arel::Nodes.build_quoted('name'))
    #   Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
    #                                   Arel::Nodes.build_quoted('code'))
    #   Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
    #                                   Arel::Nodes.build_quoted('ident'))
    # end
  end
end
