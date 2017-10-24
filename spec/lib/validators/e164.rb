# https://en.wikipedia.org/wiki/E.164

RSpec.shared_examples 'e164' do
  describe 'validation' do
    it 'rejects invalid format' do
      model.send("#{attribute}=", '+.1')
      model.validate
      expect(model.errors).to be_added(attribute, :invalid)
    end

    it 'rejects longer than max length' do
      model.send("#{attribute}=", '1' * 18)
      model.validate
      expect(model.errors).to be_added(attribute, :too_long, count: 17)
    end

    it 'accepts valid format' do
      model.send("#{attribute}=", '+123.4')
      model.validate
      expect(model.errors).to_not be_added(attribute, :invalid)
    end

    it 'accepts max length' do
      model.send("#{attribute}=", '1' * 17)
      model.validate
      expect(model.errors).to_not be_added(attribute, :too_long, count: 17)
    end
  end
end
