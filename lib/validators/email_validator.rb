class EmailValidator
  def self.regexp
    Devise.email_regexp
  end

  def initialize(email)
    @email = email
  end

  def valid?
    email =~ self.class.regexp
  end

  attr_reader :email
end
