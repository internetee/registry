class BankStatement < ActiveRecord::Base
  has_many :bank_transactions

  attr_accessor :th6_file

  def import
    import_th6_file && save
  end

  def import_th6_file
    return false unless th6_file

    th6_file.open.each_line do |row|
      bt_params = parse_th6_row(row)
      next unless bt_params
      bank_transactions.build(bt_params)
    end
  end

  def parse_th6_row(row)
    return parse_th6_header(row) if row[4, 3].strip == '000'
    return if row[4, 3].strip == '999' # skip footer
    return unless row[4, 1].strip == '1' # import only transactions
    return unless row[266, 2].strip == 'C' # import only Credit transactions

    {
      paid_at: DateTime.strptime(row[5, 8].strip, '%Y%m%d'),
      bank_reference: row[5, 16].strip,
      iban: row[25, 20].strip,
      currency: row[45, 3].strip,
      buyer_bank_code: row[48, 3].strip,
      buyer_iban: row[51, 32].strip,
      buyer_name: row[83, 35].strip,
      document_no: row[118, 8].strip,
      description: row[126, 140].strip,
      sum: BigDecimal.new(row[268, 12].strip) / BigDecimal.new('100.0'),
      reference_no: row[280, 35].strip
    }
  end

  def parse_th6_header(row)
    self.bank_code = row[7, 3].strip
    self.iban = row[10, 20].strip
    self.queried_at = DateTime.strptime(row[30, 10].strip, '%y%m%d%H%M')
    nil
  end
end
