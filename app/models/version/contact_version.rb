class Version::ContactVersion < PaperTrail::Version
  extend ToCsv
  include VersionSession

  self.table_name    = :log_contacts
  self.sequence_name = :log_contacts_id_seq

  def as_csv_row
    contact = ObjectVersionsParser.new(self).parse

    [
      contact.name,
      contact.code,
      contact.ident_human_description,
      contact.registrar,
      event,
      created_at.to_formatted_s(:db)
    ]
  end

  def self.csv_header
    ['Name', 'ID', 'Ident', 'Registrar', 'Action', 'Created at'].freeze
  end
end
