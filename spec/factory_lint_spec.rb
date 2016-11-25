require_relative 'rails_helper'

RSpec.describe 'FactoryGirl', db: true do
  it 'lints factories' do
    FactoryGirl.lint
  end
end
