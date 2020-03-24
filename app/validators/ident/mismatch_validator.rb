class Ident::MismatchValidator < ActiveModel::Validator
  Mismatch = Struct.new(:type, :country)

  def self.mismatches
    [
      Mismatch.new('birthday', Country.new('EE')),
    ]
  end

  def validate(record)
    record.errors.add(:base, :mismatch, type: record.type, country: record.country) if mismatched?(record)
  end

  private

  def mismatched?(record)
    mismatch = Mismatch.new(record.type, record.country)
    self.class.mismatches.include?(mismatch)
  end
end
