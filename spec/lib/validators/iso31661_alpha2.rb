# https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2

RSpec.shared_examples 'iso31661_alpha2' do
  describe 'validation' do
    it 'rejects invalid' do
      model.send("#{attribute}=", 'invalid')
      model.validate
      expect(model.errors).to be_added(attribute, :invalid_iso31661_alpha2)
    end

    it 'accepts valid' do
      model.send("#{attribute}=", 'US')
      model.validate
      expect(model.errors).to_not be_added(attribute, :invalid_iso31661_alpha2)
    end
  end
end
