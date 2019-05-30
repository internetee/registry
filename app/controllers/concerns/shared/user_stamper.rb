module Shared::UserStamper
  extend ActiveSupport::Concern

  # def stamp(obj)
  # return false if obj.nil? || !obj.has_attribute?(:created_by_id && :updated_by_id)

  # if obj.new_record?
  # obj.created_by_id = current_user.id
  # else
  # obj.updated_by_id = current_user.id
  # end

  # true
  # end
end
