require 'rails_helper'

describe Dnskey do
  before(:each) do
    create_settings
  end

  it { should belong_to(:domain) }

  # rubocop: disable Style/NumericLiterals
  it 'generates correct DS digest and DS key tag for ria.ee' do
    d = Fabricate(:domain, name: 'ria.ee')
    dk = d.dnskeys.first

    dk.generate_digest
    expect(dk.ds_digest).to eq('0B62D1BC64EFD1EE652FB102BDF1011BF514CCD9A1A0CFB7472AEA3B01F38C92')
    expect(dk.ds_key_tag).to eq(30607)
  end

  it 'generates correct DS digest and DS key tag for emta.ee' do
    d = Fabricate(:domain, name: 'emta.ee')

    dk = d.dnskeys.first
    dk.public_key = 'AwEAAfB9jK8rj/FAdE3t9bYXiTLpelwlgUyxbHEtvMvhdxs+yHv0h9fE '\
                    '710u94LPAeVmXumT6SZPsoo+ALKdmTexkcU9DGQvb2+sPfModBKM/num '\
                    'rScUw1FBe3HwRa9SqQpgpnCjIt0kEVKHAQdLOP86YznSA9uHAg9TTJuT '\
                    'LkUtgtmwNAVFr6/mG+smE1v5NbxPccsFwVTA/T1IyaI4Z48VGCP2WNro '\
                    'R7P6vet1gWhssirnnVYnur8DwWuMJ89o/HjzXeiEGUB8k5SOX+//67FN '\
                    'm8Zs+1ObuAfY8xAHe0L5bxluEbh1T1ARp41QX77EMKVbkcSj7nuBeY8H '\
                    'KiN8HsTvmZyDbRAQQaAJi68qOXsUIoQcpn89PoNoc60F7WlueA6ExSGX '\
                    'KMWIH6nfLXFgidoZ6HxteyUUnZbHEdULjpAoCRuUDjjUnUgFS7eRANfw '\
                    'RCcu9aLziMDp4UU61zVjtmQ7xn3G2W2+2ycqn/vEl/yFyBmHZ+7stpoC '\
                    'd6NTZUn4/ellYSm9lx/vaXdPSinARpYMWtU79Hu/VRifaCQjYkBGAMwK '\
                    'DshX4yJPjza/bqo0XV4WHj1szDFHe0tLN7g1Ojwtf5FR0zyHU3FN9uUa '\
                    'y8a+dowd/fqOQA1jXR04g2PIfFYe0VudCEpmxSV9YDoqjghHeIKUX7Jn '\
                    'KiHL5gk404S5a/Bv'

    dk.save
    expect(dk.ds_digest).to eq('D7045D3C2EF7332409A132D935C8E2834A2AAB769B35BC370FA68C9445398288')
    expect(dk.ds_key_tag).to eq(31051)
  end
end
