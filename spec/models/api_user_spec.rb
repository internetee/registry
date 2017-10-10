require 'rails_helper'

RSpec.describe ApiUser do
  context 'with invalid attribute' do
    before do
      @api_user = ApiUser.new
    end

    it 'should not be valid' do
      @api_user.valid?
      @api_user.errors.full_messages.should match_array([
        "Password Password is missing",
        "Password is too short (minimum is #{ApiUser.min_password_length} characters)",
        "Registrar Registrar is missing",
        "Username Username is missing",
        "Roles is missing"
      ])
    end

    it 'should not have any versions' do
      @api_user.versions.should == []
    end

    it 'should be active by default' do
      @api_user.active.should == true
    end
  end

  context 'with valid attributes' do
    before do
      @api_user = Fabricate(:api_user)
    end

    it 'should be valid' do
      @api_user.valid?
      @api_user.errors.full_messages.should match_array([])
    end

    it 'should be valid twice' do
      @api_user = Fabricate(:api_user)
      @api_user.valid?
      @api_user.errors.full_messages.should match_array([])
    end

    it 'should have one version' do
      with_versioning do
        @api_user.versions.should == []
        @api_user.username = 'newusername'
        @api_user.save
        @api_user.errors.full_messages.should match_array([])
        @api_user.versions.size.should == 1
      end
    end
  end

  describe '::min_password_length', db: false do
    it 'returns minimum password length' do
      expect(described_class.min_password_length).to eq(6)
    end
  end

  describe '#linked_users' do
    it 'returns users with the same identity code' do
      api_user = create(:api_user, id: 1, identity_code: 'test')
      create(:api_user, id: 2, identity_code: 'test')

      expect(api_user.linked_users.ids).to include(2)
    end

    it 'does not return users with another identity code' do
      api_user = create(:api_user, id: 1, identity_code: 'test')
      create(:api_user, id: 2, identity_code: 'another')

      expect(api_user.linked_users.ids).to_not include(2)
    end

    it 'does not return itself' do
      api_user = create(:api_user)
      expect(api_user.linked_users).to be_empty
    end

    it 'returns none if identity code is absent' do
      api_user = create(:api_user, identity_code: nil)
      create(:api_user, identity_code: nil)

      expect(api_user.linked_users).to be_empty
    end

    it 'returns none if identity code is empty' do
      api_user = create(:api_user, identity_code: '')
      create(:api_user, identity_code: '')

      expect(api_user.linked_users).to be_empty
    end
  end

  describe '#linked_with?', db: false do
    it 'returns true if identity codes match' do
      api_user = described_class.new(identity_code: 'test')
      another_api_user = described_class.new(identity_code: 'test')

      expect(api_user.linked_with?(another_api_user)).to be true
    end

    it 'returns false if identity codes do not match' do
      api_user = described_class.new(identity_code: 'test')
      another_api_user = described_class.new(identity_code: 'another-test')

      expect(api_user.linked_with?(another_api_user)).to be false
    end
  end

  describe '#login', db: false do
    it 'is alias to #username' do
      user = described_class.new(username: 'test-username')
      expect(user.login).to eq('test-username')
    end
  end

  describe '#registrar_name', db: false do
    it 'delegates to registrar' do
      registrar = Registrar.new(name: 'test name')
      user = described_class.new(registrar: registrar)

      expect(user.registrar_name).to eq('test name')
    end
  end
end
