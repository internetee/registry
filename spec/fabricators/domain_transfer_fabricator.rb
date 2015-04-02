Fabricator(:domain_transfer) do
  domain
  transfer_from { Fabricate(:registrar) }
  transfer_to { Fabricate(:registrar) }
end
