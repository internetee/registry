module Audit
  class Contact < Base
    self.table_name = 'audit.contacts'

    ransacker :new_name do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('name'))
    end

    ransacker :new_code do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('code'))
    end

    ransacker :new_ident do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:new_value],
                                      Arel::Nodes.build_quoted('ident'))
    end

    ransacker :old_name do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:old_value],
                                      Arel::Nodes.build_quoted('name'))
    end

    ransacker :new_code do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:old_value],
                                      Arel::Nodes.build_quoted('code'))
    end

    ransacker :new_ident do |parent|
      Arel::Nodes::InfixOperation.new('->>', parent.table[:old_value],
                                      Arel::Nodes.build_quoted('ident'))
    end
  end
end
