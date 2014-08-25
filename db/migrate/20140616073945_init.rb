class Init < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :name # ascii, utf8 will be converted on the fly
      t.integer :registrar_id # registripidaja
      t.datetime :registered_at
      t.string :status
      t.datetime :valid_from
      t.datetime :valid_to
      t.integer :owner_contact_id
      t.integer :admin_contact_id
      t.integer :technical_contact_id
      t.integer :ns_set_id
      t.string :auth_info
      # t.integer :keyset_id #dnssec

      t.timestamps
    end

    # this will be a huge table?
    create_table :contacts do |t|
      t.string :code # CID:STRING:OID
      t.string :name
      t.string :type # organisation / juridical / citizen #rails specific variable
      t.string :reg_no # identity code or registration number for organisation

      # can a person have one or more of these contacts?
      t.string :phone
      t.string :email
      t.string :fax

      t.timestamps
    end

    create_table :addresses do |t| # needs a better name?
      t.integer :contact_id
      t.integer :country_id
      t.string :city
      t.string :address # Street + house + apartment #needs a better name
      t.string :zip

      t.timestamps
    end

    create_table :country_id do |t|
      t.string :iso
      t.string :name

      t.timestamps
    end

    create_table :registrars do |t|
      t.string :name
      t.string :reg_no
      t.string :vat_no
      t.string :address
      t.integer :country_id
      t.string :billing_address

      t.timestamps
    end

    # legal documents
    # create_table :documents do |t|
    #   t.integer :domain_id
    #   t.string :name
    #   t.status :document_type #if this is registration document or deletion document

    #   t.timestamps
    # end

    create_table :ns_sets do |t|
      t.string :code # NSSID:STRING:OID
      t.integer :registrar_id
      t.string :auth_info # password for transferring between registrants
      t.string :report_level

      # t.integer :technical_contact_id # reference to technical contact -
      # does each ns_set have spearate technical contacts or can the contacts be inherited from the registrar?

      t.timestamps
    end

    create_table :nameservers_ns_sets do |t|
      t.integer :nameserver_id
      t.integer :ns_set_id
    end

    create_table :nameservers do |t|
      t.string :name
      t.string :ip
      t.integer :ns_set_id

      t.timestamps
    end

    # devise for login
    # cancan for securing
    # what to do with API users?
    create_table :users do |t|
      t.string :username
      t.string :password
      t.integer :role_id # can user have more than one role?

      t.timestamps
    end

    create_table :roles do |t|
      t.string :name

      t.timestamps
    end

    create_table :rights_roles do |t|
      t.integer :right_id
      t.integer :role_id
    end

    create_table :rights do |t|
      t.string :code # LOG_IN, SEE_DOMAINS, etc

      t.timestamps
    end
  end
end
