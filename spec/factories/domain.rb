FactoryGirl.define do
  factory :domain do
    sequence(:name) { |n| "test#{n}.com" }
    period 1
    period_unit 'y' # Year
    registrar
    registrant

    after :build do |domain|
      domain.admin_domain_contacts << FactoryGirl.build(:admin_domain_contact)
      domain.tech_domain_contacts << FactoryGirl.build(:tech_domain_contact)
    end

    factory :domain_without_force_delete do
      force_delete_time nil
      statuses []
    end

    factory :domain_discarded do
      statuses [DomainStatus::DELETE_CANDIDATE]
    end
  end
end
