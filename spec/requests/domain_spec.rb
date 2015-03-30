require 'rails_helper'

describe Repp::DomainV1 do
  before :all do
    create_settings
    @registrar1 = Fabricate(:registrar1)
    @api_user   = Fabricate(:gitlab_api_user, registrar: @registrar1)
    Fabricate.times(2, :domain, registrar: @api_user.registrar)
  end

  describe 'GET /repp/v1/domains', autodoc: true do
    it 'returns domains of the current registrar' do

      get_with_auth '/repp/v1/domains', { limit: 1, details: true }, @api_user
      response.status.should == 200

      body = JSON.parse(response.body)
      body['total_number_of_records'].should == 2

      # TODO: Maybe there is a way not to convert from and to json again
      body['domains'].to_json.should == @api_user.reload.registrar.domains.limit(1).to_json

      log = ApiLog::ReppLog.last
      log[:request_path].should == '/repp/v1/domains'
      log[:request_method].should == 'GET'
      log[:request_params].should == '{"limit":1,"details":"true"}'
      log[:response_code].should == '200'
      log[:api_user_name].should == 'gitlab'
      log[:api_user_registrar].should == 'registrar1'
      log[:ip].should == '127.0.0.1'
    end

    it 'returns domain names with offset' do
      get_with_auth '/repp/v1/domains', { offset: 1 }, @api_user
      response.status.should == 200

      body = JSON.parse(response.body)
      body['total_number_of_records'].should == 2

      # TODO: Maybe there is a way not to convert from and to json again
      body['domains'].to_json.should == @api_user.reload.registrar.domains.offset(1).pluck(:name).to_json

      log = ApiLog::ReppLog.last
      log[:request_path].should == '/repp/v1/domains'
      log[:request_method].should == 'GET'
      log[:request_params].should == '{"offset":1}'
      log[:response_code].should == '200'
      log[:api_user_name].should == 'gitlab'
      log[:api_user_registrar].should == 'registrar1'
      log[:ip].should == '127.0.0.1'
    end

    it 'returns domain names of the current registrar' do
      get_with_auth '/repp/v1/domains', {}, @api_user
      response.status.should == 200

      body = JSON.parse(response.body)
      body['total_number_of_records'].should == 2

      # TODO: Maybe there is a way not to convert from and to json again
      body['domains'].to_json.should == @api_user.reload.registrar.domains.pluck(:name).to_json

      log = ApiLog::ReppLog.last
      log[:request_path].should == '/repp/v1/domains'
      log[:request_method].should == 'GET'
      log[:request_params].should == '{}'
      log[:response_code].should == '200'
      log[:api_user_name].should == 'gitlab'
      log[:api_user_registrar].should == 'registrar1'
      log[:ip].should == '127.0.0.1'
    end

    it 'returns an error with invalid parameters in domain index' do
      get_with_auth '/repp/v1/domains', { limit: 0 }, @api_user
      response.status.should == 400

      body = JSON.parse(response.body)
      body['error'].should == 'limit does not have a valid value'

      log = ApiLog::ReppLog.last
      log[:request_path].should == '/repp/v1/domains'
      log[:request_method].should == 'GET'
      log[:request_params].should == '{}'
      log[:response_code].should == '200'
      log[:api_user_name].should == 'gitlab'
      log[:api_user_registrar].should == 'registrar1'
      log[:ip].should == '127.0.0.1'
    end
  end
end
