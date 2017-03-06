require 'rails_helper'

RSpec.describe Disputes::Close do
  describe '#close' do
    let(:dispute_close) { described_class.new(dispute: dispute) }
    let!(:dispute) { create(:dispute) }

    it 'deletes dispute' do
      expect { dispute_close.close }.to change { Dispute.count }.from(1).to(0)
    end
  end
end
