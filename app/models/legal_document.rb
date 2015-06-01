class LegalDocument < ActiveRecord::Base
  include Versions # version/legal_document_version.rb
  belongs_to :documentable, polymorphic: true

  TYPES = %w(pdf bdoc ddoc zip rar gz tar 7z odt doc docx)

  attr_accessor :body

  before_save :save_to_filesystem
  def save_to_filesystem
    loop do
      rand = SecureRandom.random_number.to_s.last(4)
      next if rand.to_i == 0 || rand.length < 4
      self.path = "#{ENV['legal_documents_dir']}/#{Time.zone.now.to_formatted_s(:number)}_#{rand}.#{document_type}"
      break unless File.file?(path)
    end

    File.open(path, 'wb') { |f| f.write(Base64.decode64(body)) } unless Rails.env.test?
    self.path = path
  end
end
