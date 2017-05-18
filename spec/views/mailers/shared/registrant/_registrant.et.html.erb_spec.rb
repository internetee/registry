require 'rails_helper'
require_relative 'registrant_shared'

RSpec.describe 'mailers/shared/registrant/_registrant.et.html.erb' do
  include_examples 'domain mailer registrant info', 'mailers/shared/registrant/_registrant.et.html.erb'
end
