require 'rails_helper'
require_relative 'pending_deleted_shared'

RSpec.describe 'mailers/domain_mailer/pending_deleted.text.erb' do
  before :example do
    stub_template 'mailers/domain_mailer/registrar/_registrar.et.text' => 'test registrar estonian'
    stub_template 'mailers/domain_mailer/registrar/_registrar.en.text' => 'test registrar english'
  end

  include_examples 'domain mailer pending deleted'
end
