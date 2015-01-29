class LegalDocument < ActiveRecord::Base
  include Versions # version/legal_document_version.rb
  belongs_to :documentable, polymorphic: true

  TYPES = %w(pdf bdoc ddoc zip rar gz tar 7z)
end
