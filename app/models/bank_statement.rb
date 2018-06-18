class BankStatement < ActiveRecord::Base
  include Versions
  has_many :bank_transactions

  accepts_nested_attributes_for :bank_transactions

  attr_accessor :th6_file

  validates :bank_code, :iban, presence: true

  FULLY_BINDED = 'fully_binded'
  PARTIALLY_BINDED = 'partially_binded'
  NOT_BINDED = 'not_binded'

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

    self.import_file_path = "#{ENV['bank_statement_import_dir']}/#{Time.zone.now.to_formatted_s(:number)}.txt"
    File.open(import_file_path, 'w') { |f| f.write(th6_file.open.read) }
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

  # TODO: Cache this to database so it can be used for searching
  def status
    if bank_transactions.unbinded.count == bank_transactions.count
      NOT_BINDED
    elsif bank_transactions.unbinded.count == 0
      FULLY_BINDED
    else
      PARTIALLY_BINDED
    end
  end

  def not_binded?
    status == NOT_BINDED
  end

  def partially_binded?
    status == PARTIALLY_BINDED
  end

  def fully_binded?
    status == FULLY_BINDED
  end

  def bind_invoices
    bank_transactions.unbinded.each(&:autobind_invoice)
  end
end
