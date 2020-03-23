module Audit
  class Domain < Base
    self.table_name = 'audit.domains'

    ransacker :link_type do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('name'))
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('registrant_id'))
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('registrar_id'))
    end

    scope 'not_creates', -> { where.not(action: 'CREATE') }

    def uuid
      new_value['uuid']
    end

    def previous
      self.class.where(object_id: object_id).where('id < ?', id).last
    end
  end
end
