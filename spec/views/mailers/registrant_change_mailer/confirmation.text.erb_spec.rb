require 'rails_helper'
require_relative 'confirmation_shared'

RSpec.describe 'mailers/registrant_change_mailer/confirmation.text.erb' do
  before :example do
    stub_template 'mailers/shared/registrar/_registrar.et.text' => 'test registrar estonian'
    stub_template 'mailers/shared/registrar/_registrar.en.text' => 'test registrar english'
    stub_template 'mailers/shared/registrant/_registrant.et.text' => 'test new registrant estonian'
    stub_template 'mailers/shared/registrant/_registrant.en.text' => 'test new registrant english'
  end

  include_examples 'domain mailer pending update request for old registrant'
end
