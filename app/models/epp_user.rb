class EppUser < ActiveRecord::Base
  # TODO should have max request limit per day
  belongs_to :registrar
  has_many :contacts

  attr_accessor :registrar_typeahead

  def registrar_typeahead
    @registrar_typeahead || registrar || nil
  end

  def to_s
    username
  end
end
