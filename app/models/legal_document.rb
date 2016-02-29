class LegalDocument < ActiveRecord::Base
  if ENV['legal_document_types'].present?
    TYPES = ENV['legal_document_types'].split(',').map(&:strip)
  else
    TYPES = %w(pdf bdoc ddoc zip rar gz tar 7z odt doc docx).freeze
  end

  attr_accessor :body

  belongs_to :documentable, polymorphic: true

  validates :body, length: { minimum: (1.37 * 1.4).ceil }

  before_create :add_creator
  before_save   :save_to_filesystem



  def save_to_filesystem
    loop do
      rand = SecureRandom.random_number.to_s.last(4)
      next if rand.to_i == 0 || rand.length < 4

      dir = "#{ENV['legal_documents_dir']}/#{Time.zone.now.strftime('%Y/%m/%d')}"
      FileUtils.mkdir_p(dir, mode: 0775)
      self.path = "#{dir}/#{Time.zone.now.to_formatted_s(:number)}_#{rand}.#{document_type}"
      break unless File.file?(path)
    end

    File.open(path, 'wb') { |f| f.write(Base64.decode64(body)) } unless Rails.env.test?
    self.path = path
  end

  def add_creator
    self.creator_str = ::PaperTrail.whodunnit
    true
  end
end
