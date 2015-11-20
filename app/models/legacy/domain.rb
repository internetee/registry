module Legacy
  class Domain < Db
    self.table_name = :domain

    belongs_to :object_registry, foreign_key: :id
    belongs_to :object, foreign_key: :id
    belongs_to :nsset, foreign_key: :nsset
    # belongs_to :registrant, foreign_key: :registrant, primary_key: :legacy_id, class_name: '::Contact'

    has_many :object_states, foreign_key: :object_id
    has_many :dnskeys, foreign_key: :keysetid, primary_key: :keyset
    has_many :domain_contact_maps, foreign_key: :domainid
    has_many :nsset_contact_maps, foreign_key: :nssetid, primary_key: :nsset
    has_many :domain_histories, foreign_key: :id
    alias_method :history, :domain_histories


    def new_states
      domain_statuses = []
      object_states.valid.each do |state|
        next if state.name.blank?
        domain_statuses << state.name
      end

      # OK status is default
      domain_statuses << DomainStatus::OK if domain_statuses.empty?
    end
  end
end
