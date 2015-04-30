require 'rails_helper'

describe Repp::ContactV1 do
  before :all do
    @api_user = Fabricate(:gitlab_api_user)
    Fabricate.times(2, :contact, registrar: @api_user.registrar)
    Fabricate.times(2, :contact)
  end

  describe 'GET /repp/v1/contacts' do
    it 'returns contacts of the current registrar', autodoc: true, route_info_doc: true do
      get_with_auth '/repp/v1/contacts', { limit: 1, details: true }, @api_user
      expect(response.status).to eq(200)

      body = JSON.parse(response.body)
      body['total_number_of_records'].should == 2

      # TODO: Maybe there is a way not to convert from and to json again
      expect(body['contacts'].to_json).to eq(@api_user.registrar.contacts.limit(1).to_json)

      log = ApiLog::ReppLog.last
      expect(log[:request_path]).to eq('/repp/v1/contacts')
      expect(log[:request_method]).to eq('GET')
      expect(log[:request_params]).to eq('{"limit":1,"details":"true"}')
      expect(log[:response].length).to be > 20
      expect(log[:response_code]).to eq('200')
      expect(log[:api_user_name]).to eq('gitlab')
      expect(log[:ip]).to eq('127.0.0.1')
    end

    it 'returns contact names with offset', autodoc: true do
      get_with_auth '/repp/v1/contacts', { offset: 1 }, @api_user
      expect(response.status).to eq(200)

      body = JSON.parse(response.body)
      body['total_number_of_records'].should == 2

      # TODO: Maybe there is a way not to convert from and to json again
      expect(body['contacts'].to_json).to eq(@api_user.registrar.contacts.offset(1).pluck(:code).to_json)

      log = ApiLog::ReppLog.last
      expect(log[:request_path]).to eq('/repp/v1/contacts')
      expect(log[:request_method]).to eq('GET')
      expect(log[:request_params]).to eq('{"offset":1}')
      expect(log[:response].length).to be > 20
      expect(log[:response_code]).to eq('200')
      expect(log[:api_user_name]).to eq('gitlab')
      expect(log[:ip]).to eq('127.0.0.1')
    end

    it 'returns contact names of the current registrar' do
      get_with_auth '/repp/v1/contacts', {}, @api_user
      expect(response.status).to eq(200)

      body = JSON.parse(response.body)
      body['total_number_of_records'].should == 2

      # TODO: Maybe there is a way not to convert from and to json again
      expect(body['contacts'].to_json).to eq(@api_user.registrar.contacts.pluck(:code).to_json)

      log = ApiLog::ReppLog.last
      expect(log[:request_path]).to eq('/repp/v1/contacts')
      expect(log[:request_method]).to eq('GET')
      expect(log[:request_params]).to eq('{}')
      expect(log[:response].length).to be > 20
      expect(log[:response_code]).to eq('200')
      expect(log[:api_user_name]).to eq('gitlab')
      expect(log[:ip]).to eq('127.0.0.1')
    end

    it 'returns an error with invalid parameters in contact index' do
      get_with_auth '/repp/v1/contacts', { limit: 0 }, @api_user
      expect(response.status).to eq(400)

      body = JSON.parse(response.body)
      body['error'].should == 'limit does not have a valid value'

      # TODO: Log failed API requests too
    end
  end
end
