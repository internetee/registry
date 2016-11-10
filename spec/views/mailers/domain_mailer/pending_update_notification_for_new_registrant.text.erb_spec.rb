require 'rails_helper'

RSpec.describe 'mailers/domain_mailer/pending_update_notification_for_new_registrant.text.erb' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:lang_count) { 2 }

  before :example do
    assign(:domain, domain)
  end

  domain_attributes = %i(
    name
  )

  domain_attributes.each do |attr_name|
    it "has domain #{attr_name}" do
      expect(domain).to receive(attr_name).exactly(lang_count).times.and_return("test domain #{attr_name}")
      render
      expect(rendered).to have_text("test domain #{attr_name}", count: lang_count)
    end
  end
end
