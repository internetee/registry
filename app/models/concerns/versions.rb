# Papertrail concerns is mainly tested at country spec
module Versions
  extend ActiveSupport::Concern

  included do
    has_paper_trail class_name: "#{model_name}Version"

    before_create :add_creator
    before_create :add_updator
    before_update :add_updator

    def add_creator
      self.creator_str = ::PaperTrail.whodunnit
      true
    end

    def add_updator
      self.updator_str = ::PaperTrail.whodunnit
      true
    end
  end
end
