require 'rails_helper'

describe Dnskey do
  before(:each) do
    create_settings
  end

  it { should belong_to(:domain) }

  it 'generates digest' do
    d = Fabricate(:domain, name: 'ria.ee')
    ds = d.dnskeys.first

    ds.generate_digest
    expect(ds.ds_digest).to eq('0B62D1BC64EFD1EE652FB102BDF1011BF514CCD9A1A0CFB7472AEA3B01F38C92')
  end
end
