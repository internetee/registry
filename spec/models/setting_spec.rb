require 'rails_helper'

describe Setting do
  it 'returns value' do
    expect(Setting.ns_min_count).to eq(2)
    Setting.ns_min_count = '2'
    expect(Setting.ns_min_count).to eq('2')
    Setting.ns_min_count = true
    expect(Setting.ns_min_count).to eq(true)
  end
end
