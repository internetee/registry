require 'rails_helper'

RSpec.shared_examples 'domain mailer registrant info' do |template_path|
  let(:template_path) { template_path }
  let(:registrant) { instance_spy(RegistrantPresenter) }

  before :example do
    allow(view).to receive(:registrant).and_return(registrant)
    allow(view).to receive(:address_processing)
  end

  it 'has name' do
    allow(registrant).to receive(:name).and_return('test name')
    render template: template_path
    expect(rendered).to have_text('test name')
  end

  it 'has ident' do
    allow(registrant).to receive(:ident).and_return('test ident')
    render template: template_path
    expect(rendered).to have_text('test ident')
  end

  context 'when :with_phone is true' do
    it 'has phone' do
      allow(registrant).to receive(:phone).and_return('test phone')
      render template: template_path, locals: { with_phone: true }
      expect(rendered).to have_text('test phone')
    end
  end

  context 'when :with_phone is false' do
    it 'has no phone' do
      allow(registrant).to receive(:phone).and_return('test phone')
      render template: template_path, locals: { with_phone: false }
      expect(rendered).to_not have_text('test phone')
    end
  end

  address_attributes = %i[street city state zip country]

  context 'when address processing is enabled' do
    before :example do
      allow(view).to receive(:address_processing).and_return(true)
    end

    address_attributes.each do |attr_name|
      it "has #{attr_name}" do
        allow(registrant).to receive(attr_name).and_return("test #{attr_name}")
        render template: template_path
        expect(rendered).to have_text("test #{attr_name}")
      end
    end

    it 'has no ident country' do
      allow(registrant).to receive(:ident_country).and_return('test ident country')
      render template: template_path
      expect(rendered).to_not have_text('test ident country')
    end
  end

  context 'when address processing is disabled' do
    before :example do
      allow(view).to receive(:address_processing).and_return(false)
    end

    address_attributes.each do |attr_name|
      it "has no #{attr_name}" do
        allow(registrant).to receive(attr_name).and_return("test #{attr_name}")
        render template: template_path
        expect(rendered).to_not have_text("test #{attr_name}")
      end
    end

    it 'has ident country' do
      allow(registrant).to receive(:ident_country).and_return('test ident country')
      render template: template_path
      expect(rendered).to have_text('test ident country')
    end
  end
end
