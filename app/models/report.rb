# app/models/report.rb
class Report < ApplicationRecord
  validates :name, presence: true, uniqueness: true
  validates :sql_query, presence: true

  belongs_to :creator, class_name: 'AdminUser', foreign_key: :created_by, optional: true

  before_validation :parse_json_parameters

  def self.ransackable_attributes(*)
    authorizable_ransackable_attributes
  end

  private

  def parse_json_parameters
    if parameters.present? && parameters.is_a?(String)
      self.parameters = JSON.parse(parameters)
    else
      self.parameters = nil
    end
  rescue JSON::ParserError => e
    errors.add(:parameters, "Invalid JSON format: #{e.message}")
  end
end
