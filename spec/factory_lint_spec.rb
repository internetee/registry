require_relative 'rails_helper'

RSpec.describe 'FactoryGirl', db: true do
  before :example do
    allow(Contact).to receive(:address_processing?).and_return(false)
  end

  it 'lints factories' do
    factories_to_lint = FactoryGirl.factories.reject do |factory|
      %i(reserved_domain).include?(factory.name) || factory.name.to_s =~ /^domain/ # Ignore the ones with domain_name validator
    end

    FactoryGirl.lint factories_to_lint
  end
end
