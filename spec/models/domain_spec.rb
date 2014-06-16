require "rails_helper"

describe Domain do
  it { should belong_to(:registrar) }
  it { should belong_to(:ns_set) }
  it { should belong_to(:admin_contact) }
  it { should belong_to(:owner_contact) }
  it { should belong_to(:technical_contact) }

  it 'creates a resource' do
    d = Fabricate(:domain)
    expect(d.name).to_not be_nil
  end
end
