class Right < ActiveRecord::Base
  # rubocop: disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :roles
  # rubocop: enable Rails/HasAndBelongsToMany
end
