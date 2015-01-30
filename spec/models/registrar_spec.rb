require 'rails_helper'

describe Registrar do
  it { should belong_to(:country) }
  it { should have_many(:domains) }
  it { should have_many(:api_users) }
  it { should have_many(:messages) }

  context 'with invalid attribute' do
    before :all do
      @registrar = Registrar.new
    end

    it 'is not valid' do
      @registrar.valid?
      @registrar.errors.full_messages.should match_array([
        'Address is missing',
        'Contact e-mail is missing',
        'Country is missing',
        'Name is missing',
        'Reg no is missing'
      ])
    end

    it 'returns an error with invalid email' do
      @registrar.email = 'bla'
      @registrar.billing_email = 'bla'

      @registrar.valid?
      @registrar.errors[:email].should == ['is invalid']
      @registrar.errors[:billing_email].should == ['is invalid']
    end


  end
end
