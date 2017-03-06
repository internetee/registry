require 'rails_helper'

RSpec.describe 'admin/reserved_domains/_reserved_domain' do
  let(:presenter) { instance_spy(ReservedDomainPresenter) }

  before :example do
    expect(ReservedDomainPresenter).to receive(:new).and_return(presenter)
  end

  visible_attributes = %i(
    name
    password
    create_time
    update_time
    edit_btn
    delete_btn
  )

  visible_attributes.each_with_index do |attr_name|
    it "has #{attr_name}" do
      expect(presenter).to receive(attr_name).and_return(attr_name.to_s)
      render
      expect(rendered).to have_text(attr_name.to_s)
    end
  end
end
