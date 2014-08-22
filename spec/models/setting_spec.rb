require "rails_helper"

describe Setting do
  it { should belong_to(:setting_group) }

  it 'validates code uniqueness' do
    sg = Fabricate(:setting_group)
    sg.settings.build(code: 'this_is_code')
    expect(sg.save).to be true

    sg.settings.build(code: 'this_is_code')
    expect(sg.save).to be false
    err = sg.settings.last.errors[:code].first
    expect(err).to eq('Code already exists')

    sg_2 = Fabricate(:setting_group, code: 'domain_statuses')

    sg_2.settings.build(code: 'this_is_code')
    expect(sg_2.save).to be true
  end
end
