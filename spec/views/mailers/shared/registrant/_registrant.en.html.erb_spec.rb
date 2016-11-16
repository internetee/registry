require 'rails_helper'
require_relative 'registrant_shared'

RSpec.describe 'mailers/shared/registrant/_registrant.en.html.erb' do
  include_examples 'domain mailer registrant info'
end
