# rubocop: disable Metrics/ClassLength
class EppUser < ActiveRecord::Base
  # TODO: should have max request limit per day
  belongs_to :registrar
  has_many :contacts

  validates :username, :password, :registrar, presence: true
  validates :username, uniqueness: true

  attr_accessor :registrar_typeahead

  def registrar_typeahead
    @registrar_typeahead || registrar || nil
  end

  def to_s
    username
  end

  def queued_messages
    registrar.messages.queued
  end
end
# rubocop: enable Metrics/ClassLength
