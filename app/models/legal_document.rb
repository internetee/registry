class LegalDocument < ActiveRecord::Base
  extend VersionCreator

  belongs_to :documentable, polymorphic: true

  if ENV['legal_document_types'].present?
    TYPES = ENV['legal_document_types'].split(',').map(&:strip)
  else
    TYPES = %w(pdf bdoc ddoc zip rar gz tar 7z odt doc docx)
  end

  attr_accessor :body

  before_save :save_to_filesystem
  def save_to_filesystem
    loop do
      rand = SecureRandom.random_number.to_s.last(4)
      next if rand.to_i == 0 || rand.length < 4

      dir = "#{ENV['legal_documents_dir']}/#{Time.zone.now.strftime('%Y/%m/%d')}"
      FileUtils.mkdir_p(dir)
      self.path = "#{dir}/#{Time.zone.now.to_formatted_s(:number)}_#{rand}.#{document_type}"
      break unless File.file?(path)
    end

    File.open(path, 'wb') { |f| f.write(Base64.decode64(body)) } unless Rails.env.test?
    self.path = path
  end
end
