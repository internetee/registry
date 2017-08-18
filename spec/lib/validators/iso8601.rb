# https://en.wikipedia.org/wiki/ISO_8601

RSpec.shared_examples 'iso8601' do
  describe 'validation' do
    it 'rejects invalid' do
      model.send("#{attribute}=", '2010-07-0')
      model.validate
      expect(model.errors).to be_added(attribute, :invalid_iso8601)
    end

    it 'accepts valid' do
      model.send("#{attribute}=", '2010-07-05')
      model.validate
      expect(model.errors).to_not be_added(attribute, :invalid_iso8601)
    end
  end
end
