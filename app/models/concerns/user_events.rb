module UserEvents
  extend ActiveSupport::Concern

  def cr_id
    if versions.first.object.nil?
      cr_registrar_id =versions.first.object_changes['registrar_id'].second
    else
      # untested, expected never to execute
      cr_registrar_id = versions.first.object['registrar_id']
    end
    if cr_registrar_id.present?
      Registrar.find(cr_registrar_id).code
    end
  end

  # TODO: remove old
  # module ClassMethods
    # def registrar_events(id)
      # registrar = Registrar.find(id)
      # return [] unless registrar
      # @events = []
      # registrar.users.each { |user| @events << user_events(user.id) }
      # registrar.epp_users.each { |user| @events << epp_user_events(user.id) }
      # @events
    # end

    # def user_events(id)
      # where(whodunnit: id.to_s)
    # end

    # def epp_user_events(id)
      # where(whodunnit: "#{id}-EppUser")
    # end
  # end
end
