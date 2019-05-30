module UserEvents
  extend ActiveSupport::Concern

  included do
    # EPP requires a server defined creator ID, which should be registrar code if we have one
    def cr_id
      # try this, rebuild user for registrar before searching history? really?
      registrar = creator.try(:registrar)
      if registrar.present? # Did creator return a kind of User that has a registrar?
        registrar.code
      else
        if versions.first.try(:object).nil?
          changes = versions.first.try(:object_changes)
          cr_registrar_id = changes['registrar_id'].second if changes.present?
        else
          # untested, expected never to execute
          cr_registrar_id = versions.first.object['registrar_id']
        end

        if cr_registrar_id.present?
          Registrar.find(cr_registrar_id).code
        else
          # cr_id optional for domain, but required for contact; but we want something here anyway
          creator_str # Fallback if we failed, maybe we can find a string here
        end
      end
    end
  end
end
