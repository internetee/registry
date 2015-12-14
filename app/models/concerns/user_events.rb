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

end
