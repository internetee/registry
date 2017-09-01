require 'rails_helper'

RSpec.describe 'Admin settings saving' do
  before do
    sign_in_to_admin_area
  end

  it 'saves integer setting' do
    allow(Setting).to receive(:integer_settings) { %i[test_setting] }
    post admin_settings_path, settings: { test_setting: '1' }
    expect(Setting.test_setting).to eq(1)
  end

  it 'saves float setting' do
    allow(Setting).to receive(:float_settings) { %i[test_setting] }
    post admin_settings_path, settings: { test_setting: '1.2' }
    expect(Setting.test_setting).to eq(1.2)
  end

  it 'saves boolean setting' do
    allow(Setting).to receive(:boolean_settings) { %i[test_setting] }
    post admin_settings_path, settings: { test_setting: 'true' }
    expect(Setting.test_setting).to be true
  end

  it 'saves string setting' do
    post admin_settings_path, settings: { test_setting: 'test' }
    expect(Setting.test_setting).to eq('test')
  end

  it 'redirects to :index' do
    post admin_settings_path, settings: { test: 'test' }
    expect(response).to redirect_to admin_settings_path
  end
end
