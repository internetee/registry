class BankTransaction < ActiveRecord::Base
  belongs_to :bank_statement
end
