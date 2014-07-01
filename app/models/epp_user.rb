class EppUser < ActiveRecord::Base
  #TODO should have max request limit per day
  belongs_to :registrar
end
