require 'rails_helper'

RSpec.describe ReservedDomainPresenter do
  let(:reserved_domain) { instance_spy(ReservedDomain) }
  let(:presenter) { described_class.new(reserved_domain: reserved_domain, view: view) }

  describe '#create_time' do
    it 'returns localized creation time ' do
      expect(reserved_domain).to receive(:created_at).and_return(Time.zone.parse('05.07.2010'))
      expect(presenter.create_time).to eq(l(Time.zone.parse('05.07.2010')))
    end
  end

  describe '#update_time' do
    it 'returns localized last modification time' do
      expect(reserved_domain).to receive(:updated_at).and_return(Time.zone.parse('05.07.2010'))
      expect(presenter.update_time).to eq(l(Time.zone.parse('05.07.2010')))
    end
  end

  describe '#edit_btn' do
    context 'when reserved domain is editable' do
      before :example do
        expect(reserved_domain).to receive(:updatable?).and_return(true)
      end

      it 'returns enabled edit button' do
        html = link_to('Edit',
                       view.edit_admin_reserved_domain_path(reserved_domain),
                       class: 'btn btn-primary btn-xs')
        expect(presenter.edit_btn).to eq(html)
      end
    end

    context 'when reserved domain is not editable' do
      before :example do
        expect(reserved_domain).to receive(:updatable?).and_return(false)
      end

      it 'returns disabled edit button' do
        html = view.content_tag(:a, 'Edit',
                                class: 'btn btn-primary btn-xs',
                                title: 'Editing is prohibited while domain name is disputed',
                                disabled: true,
                                data: {
                                  toggle: 'tooltip',
                                  placement: 'top',
                                })
        expect(presenter.edit_btn).to eq(html)
      end
    end
  end

  reserved_domain_delegatable_attributes = %i(
    name
    password
  )

  reserved_domain_delegatable_attributes.each do |attribute_name|
    describe "##{attribute_name}" do
      let(:reserved_domain) { instance_spy(ReservedDomain) }

      it 'delegates to reserved domain' do
        presenter.send(attribute_name)
        expect(reserved_domain).to have_received(attribute_name)
      end
    end
  end
end
