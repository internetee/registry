require 'rails_helper'
require_relative 'pending_deleted_shared'

RSpec.describe 'mailers/domain_mailer/pending_deleted.html.erb' do
  before :example do
    stub_template 'mailers/domain_mailer/registrar/_registrar.et.html' => 'test registrar estonian'
    stub_template 'mailers/domain_mailer/registrar/_registrar.en.html' => 'test registrar english'
  end

  include_examples 'domain mailer pending deleted'
end
