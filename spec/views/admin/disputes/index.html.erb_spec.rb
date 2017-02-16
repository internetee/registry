require 'rails_helper'

RSpec.describe 'admin/disputes/index' do
  let(:disputes) { [] }

  before :example do
    assign(:disputes, disputes)
    stub_template '_dispute.html.erb' => ''
  end

  it 'has header' do
    render
    expect(rendered).to have_text('Disputes')
  end

  context 'when disputes are present' do
    let(:disputes) { [double('dispute', to_partial_path: 'dispute')] }

    it 'has table' do
      render
      expect(rendered).to have_css('table.disputes')
    end

    it 'has no alert' do
      render
      expect(rendered).to_not have_text('No dispute found')
    end
  end

  context 'when disputes are absent' do
    let(:disputes) { [] }

    it 'has no table' do
      render
      expect(rendered).to_not have_css('table.disputes')
    end

    it 'has alert' do
      render
      expect(rendered).to have_text('No dispute found')
    end
  end
end
