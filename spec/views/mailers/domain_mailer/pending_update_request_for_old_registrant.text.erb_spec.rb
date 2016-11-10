require 'rails_helper'
require_relative 'pending_update_request_for_old_registrant_shared'

RSpec.describe 'mailers/domain_mailer/pending_update_request_for_old_registrant.text.erb' do
  before :example do
    stub_template 'mailers/domain_mailer/registrar/_registrar.et.text' => 'test registrar estonian'
    stub_template 'mailers/domain_mailer/registrar/_registrar.en.text' => 'test registrar english'
    stub_template 'mailers/domain_mailer/registrant/_registrant.et.text' => 'test new registrant estonian'
    stub_template 'mailers/domain_mailer/registrant/_registrant.en.text' => 'test new registrant english'
  end

  include_examples 'domain mailer pending update request for old registrant'
end
