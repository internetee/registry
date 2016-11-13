require 'rails_helper'
require_relative 'confirm_shared'

RSpec.describe 'mailers/registrant_change_mailer/confirm.html.erb' do
  before :example do
    stub_template 'mailers/shared/registrar/_registrar.et.html' => 'test registrar estonian'
    stub_template 'mailers/shared/registrar/_registrar.en.html' => 'test registrar english'
    stub_template 'mailers/shared/registrant/_registrant.et.html' => 'test new registrant estonian'
    stub_template 'mailers/shared/registrant/_registrant.en.html' => 'test new registrant english'
  end

  include_examples 'registrant change mailer confirm'
end
