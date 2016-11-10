require 'rails_helper'
require_relative 'registrant_shared'

RSpec.describe 'mailers/domain_mailer/registrant/_registrant.et.text.erb' do
  include_examples 'domain mailer registrant info'
end
