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
      new_value['updator_str'] || new_value['creator_str'] ||
      old_value['updator_str'] || old_value['creator_str']
    end

    def children
      new_value['children']
    end

    def next
      self.class.where("id > ?", id).first
    end

    def prev
      self.class.where("id < ?", id).last
    end
  end
end
