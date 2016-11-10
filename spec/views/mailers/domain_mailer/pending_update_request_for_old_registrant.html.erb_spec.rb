require 'rails_helper'

RSpec.describe 'mailers/domain_mailer/pending_update_request_for_old_registrant.html.erb' do
  let(:domain) { instance_spy(DomainPresenter) }
  let(:lang_count) { 2 }

  before :example do
    assign(:domain, domain)
    assign(:verification_url, 'test verification url')
  end

  it 'has verification url' do
    mention_count = 1 * lang_count
    render
    expect(rendered).to have_text('test verification url', count: mention_count)
  end

  domain_attributes = %i(
    name
  )

  domain_attributes.each do |attr_name|
    it "has :#{attr_name}" do
      expect(domain).to receive(attr_name).exactly(lang_count).times.and_return(attr_name.to_s)
      render
      expect(rendered).to have_text(attr_name.to_s, count: lang_count)
    end
  end
end
