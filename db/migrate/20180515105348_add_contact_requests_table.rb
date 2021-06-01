class AddContactRequestsTable < ActiveRecord::Migration[5.0]
  def change
    # create_table :contact_requests do |t|
    #   t.integer    :whois_record_id, null: false
    #   t.string     :secret,          null: false
    #   t.string     :email,           null: false
    #   t.string     :name,            null: false
    #   t.datetime   :valid_to,        null: false
    #   t.string     :status,          null: false, default: 'new'
    #   t.inet       :ip_address

    #   t.timestamps null: false
    # end

    # add_foreign_key :contact_requests, :whois_records
    # add_index :contact_requests, :secret, unique: true
    # add_index :contact_requests, :email
    # add_index :contact_requests, :ip_address
    # add_index :contact_requests, :whois_record_id
  end
end
