require 'rails_helper'
require_relative 'pending_update_request_for_old_registrant_shared'

RSpec.describe 'mailers/domain_mailer/pending_update_request_for_old_registrant.html.erb' do
  before :example do
    stub_template 'mailers/domain_mailer/registrar/_registrar.et.html' => 'test registrar estonian'
    stub_template 'mailers/domain_mailer/registrar/_registrar.en.html' => 'test registrar english'
    stub_template 'mailers/domain_mailer/registrant/_registrant.et.html' => 'test new registrant estonian'
    stub_template 'mailers/domain_mailer/registrant/_registrant.en.html' => 'test new registrant english'
  end

  include_examples 'domain mailer pending update request for old registrant'
end
