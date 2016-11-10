require 'rails_helper'
require_relative 'expiration_shared'

RSpec.describe 'mailers/domain_mailer/expiration.text.erb' do
  before :example do
    stub_template 'mailers/domain_mailer/registrar/_registrar.et.text' => 'test registrar estonian'
    stub_template 'mailers/domain_mailer/registrar/_registrar.en.text' => 'test registrar english'
    stub_template 'mailers/domain_mailer/registrar/_registrar.ru.text' => 'test registrar russian'
  end

  include_examples 'domain mailer expiration'
end
