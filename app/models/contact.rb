class Contact < ActiveRecord::Base
  #TODO Foreign contact will get email with activation link/username/temp password
  #TODO Phone number validation, in first phase very minimam in order to support current registries
  
  has_many :addresses

  validate :ident_must_be_valid 
  validates :phone, format: { with: /\+\d{3}\.\d+/, message: "bad format" }

  def ident_must_be_valid
    #TODO Ident can also be passport number or company registry code. 
    #so have to make changes to validations (and doc/schema) accordingly
    return true unless ident.present?
    code = Isikukood.new(ident)
    errors.add(:ident, 'bad format') unless code.valid?
  end

  class << self
    def check_availability(codes)
      codes = [codes] if codes.is_a?(String)

      res = []
      codes.each do |x|
        if Contact.find_by(code: x)
          res << {code: x, avail: 0, reason: 'in use'} 
        else
          res << {code: x, avail: 1}
        end
      end

      res
    end
  end

end
