require 'rails_helper'

RSpec.describe 'admin/registrars/_form' do
  let(:registrar) { build_stubbed(:registrar) }

  before :example do
    assign(:registrar, registrar)
    stub_template 'shared/_full_errors' => ''
  end

  it 'has website' do
    render
    expect(rendered).to have_css('[name="registrar[website]"]')
  end
end
