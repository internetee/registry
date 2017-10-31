require 'rails_helper'

describe Epp::Contact, '.check_availability' do
  before do
    create(:contact, code: 'asd12')
    create(:contact, code: 'asd13')
  end

  it 'should return array if argument is string' do
    response = Epp::Contact.check_availability('asd12')
    response.class.should == Array
    response.length.should == 1
  end

  it 'should return in_use and available codes' do
    code = Contact.first.code
    code_ = Contact.last.code

    response = Epp::Contact.check_availability([code, code_, 'asd14'])
    response.class.should == Array
    response.length.should == 3

    response[0][:avail].should == 0
    response[0][:code].should == code

    response[1][:avail].should == 0
    response[1][:code].should == code_

    response[2][:avail].should == 1
    response[2][:code].should == 'asd14'
  end
end
