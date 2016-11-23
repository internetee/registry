require 'spec_helper'

RSpec.describe EmailValidator do
  describe '#valid?' do
    subject(:valid) { described_class.new(email).valid? }

    context 'when email is valid' do
      let(:email) { 'test@test.com' }

      it 'returns truthy' do
        expect(valid).to be_truthy
      end
    end

    context 'when email is invalid' do
      let(:email) { 'invalid' }

      it 'returns falsey' do
        expect(valid).to be_falsey
      end
    end
  end
end
