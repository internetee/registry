module PhoneFormatHelperTest
  # https://en.wikipedia.org/wiki/E.164
  def assert_phone_format(contact)
    contact.phone = '+.1'
    assert contact.invalid?

    contact.phone = '+123.'
    assert contact.invalid?

    contact.phone = '+1.123456789123456'
    assert contact.invalid?

    contact.phone = '+134.1234567891234'
    assert contact.invalid?

    contact.phone = '+000.1'
    assert contact.invalid?

    contact.phone = '+123.0'
    assert contact.invalid?

    contact.phone = '+1.2'
    assert contact.valid?

    contact.phone = '+123.4'
    assert contact.valid?

    contact.phone = '+1.12345678912345'
    assert contact.valid?

    contact.phone = '+134.123456789123'
    assert contact.valid?

    contact.phone = '+134.00000000'
    assert contact.invalid?
  end
end