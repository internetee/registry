# app/models/report.rb
class Report < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :sql_query, presence: true

  belongs_to :creator, class_name: 'AdminUser', foreign_key: :created_by, optional: true

  def self.ransackable_attributes(*)
    authorizable_ransackable_attributes
  end
end
