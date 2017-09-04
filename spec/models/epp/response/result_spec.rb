require 'rails_helper'

RSpec.describe EPP::Response::Result, db: false do
  # https://tools.ietf.org/html/rfc5730#section-3
  describe '::codes' do
    it 'returns codes' do
      codes = {
        '1000' => :success,
        '1001' => :success_pending,
        '1300' => :success_empty_queue,
        '1301' => :success_dequeue,
        '2001' => :syntax_error,
        '2003' => :required_param_missing,
        '2005' => :param_syntax_error,
        '2308' => :data_management_policy_violation
      }

      expect(described_class.codes).to eq(codes)
    end
  end
end
