require 'rails_helper'
require_relative 'expired_shared'

RSpec.describe 'mailers/registrant_change_mailer/expired.html.erb' do
  before :example do
    stub_template 'mailers/shared/registrar/_registrar.et.html' => 'test registrar estonian'
    stub_template 'mailers/shared/registrar/_registrar.en.html' => 'test registrar english'
  end

  include_examples 'registrant change mailer expired'
end
