RSpec.shared_examples 'EPP contact phone' do
  context 'when phone is valid' do
    let(:phone) { '+123.4' }

    specify do
      request
      expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:completed_successfully))).to be_truthy
    end
  end

  context 'when phone has invalid format' do
    let(:phone) { '1234' }

    specify do
      request
      expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:parameter_value_syntax_error))).to be_truthy
    end
  end

  context 'when phone has only zeros' do
    let(:phone) { '+000.0' }

    specify do
      request
      expect(Epp::Response.xml(response.body).code?(Epp::Response::Result::Code.key(:parameter_value_syntax_error))).to be_truthy
    end
  end
end
