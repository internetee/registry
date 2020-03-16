module Audit
  class Base < ApplicationRecord
    def diff
      new_value.reject { |k, v| v == old_value[k] }
    end

    def object
      parent_class = self.class.name.gsub('Audit::', '').constantize
      parent_class.find(object_id)
    end

    def terminator
      new_value['updator_str'] || new_value['creator_str']
    end
  end
end
