require 'rails_helper'
require_relative 'registrant_shared'

RSpec.describe 'mailers/shared/registrant/_registrant.en.text.erb' do
  include_examples 'domain mailer registrant info'
end
