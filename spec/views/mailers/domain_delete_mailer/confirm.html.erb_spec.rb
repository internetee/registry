require 'rails_helper'
require_relative 'confirm_shared'

RSpec.describe 'mailers/domain_delete_mailer/confirm.html.erb' do
  before :example do
    stub_template 'mailers/shared/registrar/_registrar.et.html' => 'test registrar estonian'
    stub_template 'mailers/shared/registrar/_registrar.en.html' => 'test registrar english'
  end

  include_examples 'domain delete mailer confirm'
end
