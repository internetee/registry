RSpec.shared_examples 'EPP contact phone' do
  context 'when phone is valid' do
    let(:phone) { '+123.4' }

    specify do
      request
      expect(response).to have_code_of(1000)
    end
  end

  context 'when phone has invalid format' do
    let(:phone) { '1234' }

    specify do
      request
      expect(response).to have_code_of(2005)
    end
  end

  context 'when phone has only zeros' do
    let(:phone) { '+000.0' }

    specify do
      request
      expect(response).to have_code_of(2005)
    end
  end
end
