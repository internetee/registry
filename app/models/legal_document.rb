class LegalDocument < ApplicationRecord
  cattr_accessor :explicitly_write_file
  include EppErrors
  MIN_BODY_SIZE = (1.37 * 3.kilobytes).ceil

  if ENV['legal_document_types'].present?
    TYPES = ENV['legal_document_types'].split(',').map(&:strip)
  else
    TYPES = %w(pdf asice asics sce scs adoc edoc bdoc ddoc zip rar gz tar 7z odt
               doc docx).freeze
  end

  attr_accessor :body

  belongs_to :documentable, polymorphic: true


  validate :val_body_length, if: ->(file){ file.path.blank? && !Rails.env.staging?}

  before_create :add_creator
  before_save   :save_to_filesystem, if: :body

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
    binary = Base64.decode64(body)
    digest = Digest::SHA1.new.update(binary).to_s

    loop do
        rand = SecureRandom.random_number.to_s.last(4)
        next if rand.to_i == 0 || rand.length < 4
        dir = "#{ENV['legal_documents_dir']}/#{Time.zone.now.strftime('%Y/%m/%d')}"
        FileUtils.mkdir_p(dir, mode: 0775)
        self.path = "#{dir}/#{Time.zone.now.to_formatted_s(:number)}_#{rand}.#{document_type}"
        break unless File.file?(path)
    end

    File.open(path, 'wb') { |f| f.write(binary) } if !Rails.env.test? || self.class.explicitly_write_file
    self.path = path
    self.checksum = digest
  end

  def calc_checksum
    digest = Digest::SHA1.new
    digest.update File.binread(path)
    digest.to_s
  end

  def add_creator
    self.creator_str = ::PaperTrail.whodunnit
    true
  end


  def self.remove_duplicates
    start = Time.zone.now.to_f
    Rails.logger.info '-----> Removing legal documents duplicates'
    count = 0
    modified = Array.new

    LegalDocument.where(documentable_type: "Domain").where.not(checksum: [nil, ""]).find_each do |orig_legal|
      next if modified.include?(orig_legal.checksum)
      next if !File.exist?(orig_legal.path)
      modified.push(orig_legal.checksum)

      LegalDocument.where(documentable_type: "Domain", documentable_id: orig_legal.documentable_id).
          where(checksum: orig_legal.checksum).
          where.not(id: orig_legal.id).where.not(path: orig_legal.path).each do |new_legal|
        unless modified.include?(orig_legal.id)
          File.delete(new_legal.path) if File.exist?(new_legal.path)
          new_legal.update(path: orig_legal.path)
          count += 1
          Rails.logger.info "File #{new_legal.path} has been removed by Domain #{new_legal.documentable_id}. Document id: #{new_legal.id}"
        end
      end

      contact_ids = DomainVersion.where(item_id: orig_legal.documentable_id).distinct.
          pluck("object->>'registrant_id'", "object_changes->>'registrant_id'",
                "children->>'tech_contacts'", "children->>'admin_contacts'").flatten.uniq
      contact_ids = contact_ids.map{|id|
        case id
          when Hash
            id["id"]
          when String
            JSON.parse(id) rescue id.to_i
          else
            id
        end
      }.flatten.compact.uniq
      LegalDocument.where(documentable_type: "Contact", documentable_id: contact_ids).
          where(checksum: orig_legal.checksum).where.not(path: orig_legal.path).each do |new_legal|
        unless modified.include?(orig_legal.id)
          File.delete(new_legal.path) if File.exist?(new_legal.path)
          new_legal.update(path: orig_legal.path)
          count += 1
          Rails.logger.info "File #{new_legal.path} has been removed by Contact #{new_legal.documentable_id}. Document id: #{new_legal.id}"
        end
      end
    end
    Rails.logger.info "-----> Duplicates fixed for #{count} rows in #{(Time.zone.now.to_f - start).round(2)} seconds"

  end
end
