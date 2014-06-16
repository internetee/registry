class Domain < ActiveRecord::Base
  belongs_to :registrar
  belongs_to :ns_set
  belongs_to :owner_contact, class_name: 'Contact'
  belongs_to :technical_contact, class_name: 'Contact'
  belongs_to :admin_contact, class_name: 'Contact'
end
