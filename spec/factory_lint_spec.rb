require_relative 'rails_helper'

RSpec.describe 'FactoryGirl', db: true do
  before :example do
    allow(Contact).to receive(:address_processing?).and_return(false)
  end

  it 'lints factories' do
    FactoryGirl.lint
  end
end
