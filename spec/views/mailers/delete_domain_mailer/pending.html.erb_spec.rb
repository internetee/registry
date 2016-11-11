require 'rails_helper'
require_relative 'pending_shared'

RSpec.describe 'mailers/delete_domain_mailer/pending.html.erb' do
  before :example do
    stub_template 'mailers/shared/registrar/_registrar.et.html' => 'test registrar estonian'
    stub_template 'mailers/shared/registrar/_registrar.en.html' => 'test registrar english'
  end

  include_examples 'delete domain mailer pending'
end
