class RegistrantUserTest < ActiveSupport::TestCase
  def setup
    super
  end

  def teardown
    super
  end

  def test_find_or_create_by_api_data_creates_a_user
    user_data = {
      ident: '37710100070',
      first_name: 'JOHN',
      last_name: 'SMITH'
    }

    RegistrantUser.find_or_create_by_api_data(user_data)

    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('JOHN SMITH', user.username)
  end

  def test_find_or_create_by_mid_data_creates_a_user
    user_data = OpenStruct.new(user_country: 'EE', user_id_code: '37710100070',
                              user_givenname: 'JOHN', user_surname: 'SMITH')

    RegistrantUser.find_or_create_by_mid_data(user_data)
    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('JOHN SMITH', user.username)
  end

  def test_find_or_create_by_idc_with_legacy_header_creates_a_user
    header = '/C=EE/O=ESTEID/OU=authentication/CN=SMITH,JOHN,37710100070/SN=SMITH/GN=JOHN/serialNumber=37710100070'

    RegistrantUser.find_or_create_by_idc_data(header, RegistrantUser::ACCEPTED_ISSUER)

    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('JOHN SMITH', user.username)
  end

  def test_find_or_create_by_idc_with_rfc2253_header_creates_a_user
    header = 'serialNumber=37710100070,GN=JOHN,SN=SMITH,CN=SMITH\\,JOHN\\,37710100070,OU=authentication,O=ESTEID,C=EE'

    RegistrantUser.find_or_create_by_idc_data(header, RegistrantUser::ACCEPTED_ISSUER)

    user = User.find_by(registrant_ident: 'EE-37710100070')
    assert_equal('JOHN SMITH', user.username)
  end
end
