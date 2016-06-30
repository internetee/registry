class LegalDocument < ActiveRecord::Base
  include EppErrors
  MIN_BODY_SIZE = (1.37 * 3.kilobytes).ceil

  if ENV['legal_document_types'].present?
    TYPES = ENV['legal_document_types'].split(',').map(&:strip)
  else
    TYPES = %w(pdf bdoc ddoc zip rar gz tar 7z odt doc docx).freeze
  end

  attr_accessor :body

  belongs_to :documentable, polymorphic: true


  validate :val_body_length, if: ->(file){ file.path.blank? && !Rails.env.staging?}

  before_create :add_creator
  before_save   :save_to_filesystem

  def epp_code_map
    {
        '2306' => [
            [:body, :length]
        ]
    }
  end

  def val_body_length
    errors.add(:body, :length) if body.nil? || body.size < MIN_BODY_SIZE
  end


  def save_to_filesystem

    digest = Digest::SHA1.new
    ld = LegalDocument.where(checksum: digest.update(Base64.decode64(body)))

    if !ld
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
    else

      self.path = ld.first.path

    end
  end

  def add_creator
    self.creator_str = ::PaperTrail.whodunnit
    true
  end
end
