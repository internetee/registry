class Role < ActiveRecord::Base
  has_many :users
  # rubocop: disable Rails/HasAndBelongsToMany
  has_and_belongs_to_many :rights
  # rubocop: enbale Rails/HasAndBelongsToMany
end
