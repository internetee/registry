module VersionSession
  extend ActiveSupport::Concern

  included do
    before_save :add_session

    def add_session
      self.session = ::PaperSession.session
      true
    end
  end
end
