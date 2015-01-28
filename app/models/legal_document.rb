class LegalDocument < ActiveRecord::Base
  belongs_to :documentable, polymorphic: true

  TYPES = %w(pdf bdoc ddoc zip rar gz tar 7z)
end
