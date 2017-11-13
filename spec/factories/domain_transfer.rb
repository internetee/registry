FactoryBot.define do
  factory :domain_transfer do
    domain
    transfer_from { FactoryBot.create(:registrar) }
    transfer_to { FactoryBot.create(:registrar) }
  end
end
