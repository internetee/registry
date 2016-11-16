require 'rails_helper'
require_relative 'expiration_shared'

RSpec.describe 'mailers/domain_mailer/expiration.html.erb' do
  before :example do
    stub_template 'mailers/shared/registrar/_registrar.et.html' => 'test registrar estonian'
    stub_template 'mailers/shared/registrar/_registrar.en.html' => 'test registrar english'
    stub_template 'mailers/shared/registrar/_registrar.ru.html' => 'test registrar russian'
  end

  include_examples 'domain mailer expiration'
end
