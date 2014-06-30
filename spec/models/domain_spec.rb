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

    invalid = ['a.ee', "#{'a' * 64}.ee", 'ab.eu', 'test.ab.ee', '-test.ee', '-test-.ee', 'test-.ee', 'te--st.ee']

    invalid.each do |x|
      expect(Fabricate.build(:domain, name: x).valid?).to be false
    end

    valid = ['ab.ee', "#{'a' * 63}.ee", 'te-s-t.ee']

    valid.each do |x|
      expect(Fabricate.build(:domain, name: x).valid?).to be true
    end
  end
end
