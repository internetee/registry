require 'rails_helper'

describe Address do
  context 'about class' do
    it 'should have versioning enabled?' do
      Address.paper_trail_enabled_for_model?.should == true
    end

    it 'should have custom log prexied table name for versions table' do
      AddressVersion.table_name.should == 'log_addresses'
    end
  end

  context 'with invalid attribute' do
    before :all do
      @address = Address.new
    end

    it 'should not be valid' do
      @address.valid?
      @address.errors.full_messages.should match_array([
      ])
    end

    it 'should not have any versions' do
      @address.versions.should == []
    end
  end

  context 'with valid attributes' do
    before :all do
      @address = Fabricate(:address)
    end

    it 'should be valid' do
      @address.valid?
      @address.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @address = Fabricate(:address)
      @address.valid?
      @address.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @address.versions.should == []
        @address.zip = 'New zip'
        @address.save
        @address.errors.full_messages.should match_array([])
        @address.versions.size.should == 1
      end
    end
  end
end

# TODO: country issue
# describe Address, '.extract_params' do
  # it 'returns params hash' do
    # Fabricate(:country, iso: 'EE')
    # ph = { postalInfo: { name: 'fred', addr: { cc: 'EE', city: 'Village', street: 'street1' } }  }
    # expect(Address.extract_attributes(ph[:postalInfo])).to eq({
      # address_attributes: {
        # country_id: Country.find_by(iso: 'EE').id,
        # city: 'Village',
        # street: 'street1'
      # }
    # })
  # end
# end
