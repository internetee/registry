class Keyrelay < ActiveRecord::Base
  belongs_to :domain

  belongs_to :requester, class_name: 'Registrar'
  belongs_to :accepter, class_name: 'Registrar'
end
