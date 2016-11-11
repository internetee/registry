require 'rails_helper'
require_relative 'registrar_shared'

RSpec.describe 'mailers/domain_mailer/registrar/_registrar.ru.html.erb' do
  include_examples 'domain mailer registrar info'
end
