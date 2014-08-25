require 'rails_helper'

describe SettingGroup do
  it { should have_many(:settings) }
end
