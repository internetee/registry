class RefreshUpdateAttributeJob < ApplicationJob
  def perform(object_class, object_id, updated_at)
    object = object_class.constantize.find_by(id: object_id)
    object.update(:updated_at, updated_at)
  end
end
