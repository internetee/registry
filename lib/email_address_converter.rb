module EmailAddressConverter
  module_function

  def punycode_to_unicode(email)
    return email if domain(email) == 'not_found'

    local = local(email)
    domain = SimpleIDN.to_unicode(domain(email))
    "#{local}@#{domain}"&.downcase
  end

  def unicode_to_punycode(email)
    return email if domain(email) == 'not_found'

    local = local(email)
    domain = SimpleIDN.to_ascii(domain(email))
    "#{local}@#{domain}"&.downcase
  end

  def domain(email)
    Mail::Address.new(email).domain&.downcase || 'not_found'
  rescue Mail::Field::IncompleteParseError
    'not_found'
  end

  def local(email)
    Mail::Address.new(email).local&.downcase || email
  rescue Mail::Field::IncompleteParseError
    email
  end
end
