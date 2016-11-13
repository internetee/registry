require 'rails_helper'
require_relative 'rejected_shared'

RSpec.describe 'mailers/registrant_change_mailer/rejected.text.erb' do
  before :example do
    stub_template 'mailers/shared/registrar/_registrar.et.text' => 'test registrar estonian'
    stub_template 'mailers/shared/registrar/_registrar.en.text' => 'test registrar english'
  end

  include_examples 'registrant change mailer rejected'
end
