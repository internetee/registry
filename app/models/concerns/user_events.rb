module UserEvents
  extend ActiveSupport::Concern

  module ClassMethods
    def registrar_events(id)
      registrar = Registrar.find(id)
      return nil unless registrar
      @events = []
      registrar.users.each { |user| @events << user_events(user.id) }
      registrar.epp_users.each { |user| @events << user_events(user.id) }
      @events
    end

    def user_events(id)
      where(whodunnit: id.to_s)
    end

    def epp_user_events(id)
      where(whodunnit: "#{id}-EppUser")
    end


  end
end
