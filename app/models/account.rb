class Account < ActiveRecord::Base
  belongs_to :registrar
  CASH = 'cash'
end
