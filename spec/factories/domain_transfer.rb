FactoryGirl.define do
  factory :domain_transfer do
    domain
    transfer_from { FactoryGirl.create(:registrar) }
    transfer_to { FactoryGirl.create(:registrar) }
  end
end
