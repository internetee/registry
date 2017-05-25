require 'rails_helper'
require 'views/shared_examples/money_form_field'

RSpec.describe 'admin/billing/prices/_form' do
  let(:price) { build_stubbed(:price) }

  before :example do
    without_partial_double_verification do
      allow(view).to receive(:price).and_return(price)
      allow(view).to receive(:zones).and_return([])
      allow(view).to receive(:operation_categories).and_return([])
      allow(view).to receive(:durations).and_return([])
    end

    stub_template '_form_errors' => ''
  end

  describe 'price' do
    let(:field) { page.find('#price_price') }
    it_behaves_like 'money form field'
  end
end
