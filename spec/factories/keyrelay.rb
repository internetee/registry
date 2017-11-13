FactoryBot.define do
  factory :keyrelay do
    pa_date { Time.zone.now }
    expiry_relative 'P1W'
    key_data_public_key 'abc'
    key_data_flags 0
    key_data_protocol 3
    key_data_alg 3
    auth_info_pw 'abc'
    domain
  end
end
