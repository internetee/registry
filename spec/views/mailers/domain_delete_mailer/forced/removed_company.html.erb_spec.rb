require 'rails_helper'
require_relative 'removed_company'

RSpec.describe 'mailers/domain_delete_mailer/forced/removed_company.html.erb' do
  before :example do
    stub_template 'mailers/shared/registrar/_registrar.et.html' => 'test registrar estonian'
    stub_template 'mailers/shared/registrar/_registrar.en.html' => 'test registrar english'
    stub_template 'mailers/shared/registrar/_registrar.ru.html' => 'test registrar russian'
  end

  include_examples 'domain delete mailer forced'
end
