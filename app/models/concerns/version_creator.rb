module VersionCreator
  extend ActiveSupport::Concern
  
  included do
    before_create :add_creator

    def add_creator
      self.creator_str = ::PaperTrail.whodunnit
      true
    end

    def add_updator
      self.updator_str = ::PaperTrail.whodunnit
      true
    end

    # returns a user object for a reference
    def creator
      return nil if creator_str.blank?

      if creator_str =~ /^\d+-AdminUser:/
        creator = AdminUser.find_by(id: creator_str)
      elsif creator_str =~ /^\d+-ApiUser:/
        creator = ApiUser.find_by(id: creator_str)
      elsif creator_str =~ /^\d+-api-/ # depricated
        creator = ApiUser.find_by(id: creator_str)
      end

      creator.present? ? creator : creator_str
    end
  end

end