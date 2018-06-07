require 'rails_helper'

RSpec.describe Authorization::RestrictedIP do
  describe '::enabled?', db: true, settings: false do
    before do
      @original_registrar_ip_whitelist_enabled = Setting.registrar_ip_whitelist_enabled
    end

    after do
      Setting.registrar_ip_whitelist_enabled = @original_registrar_ip_whitelist_enabled
    end

    context 'when "registrar_ip_whitelist_enabled" is true' do
      before do
        Setting.registrar_ip_whitelist_enabled = true
      end

      specify do
        expect(described_class).to be_enabled
      end
    end

    context 'when "registrar_ip_whitelist_enabled" is false' do
      specify do
        expect(described_class).to_not be_enabled
      end
    end
  end

  describe '#can_access_registrar_area?', db: true do
    let(:registrar) { create(:registrar) }
    subject(:allowed) { described_class.new('127.0.0.1').can_access_registrar_area?(registrar) }

    context 'when enabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(true)
      end

      context 'when ip is whitelisted', db: true do
        let!(:white_ip) { create(:white_ip, registrar: registrar, ipv4: '127.0.0.1', interfaces: [WhiteIp::REGISTRAR]) }

        specify do
          expect(allowed).to be true
        end
      end

      context 'when ip is not whitelisted' do
        specify do
          expect(allowed).to be false
        end
      end
    end

    context 'when disabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(false)
      end

      specify do
        expect(allowed).to be true
      end
    end
  end

  describe '#can_access_registrar_area_sign_in_page?' do
    subject(:allowed) { described_class.new('127.0.0.1').can_access_registrar_area_sign_in_page? }

    context 'when enabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(true)
      end

      context 'when ip is whitelisted', db: true do
        let!(:white_ip) { create(:white_ip, ipv4: '127.0.0.1', interfaces: [WhiteIp::REGISTRAR]) }

        specify do
          expect(allowed).to be true
        end
      end

      context 'when ip is not whitelisted' do
        specify do
          expect(allowed).to be false
        end
      end
    end

    context 'when disabled' do
      before do
        allow(described_class).to receive(:enabled?).and_return(false)
      end

      specify do
        expect(allowed).to be true
      end
    end
  end
end
