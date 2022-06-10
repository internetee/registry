module Repp
  module V1
    module Registrar
      class SummaryController < BaseController
        api :GET, 'repp/v1/registrar/summary'
        desc 'check user summary info and return data'

        def index
          user = current_user
          registrar = user.registrar
          if can?(:manage, :poll)
            user_notifications = user.unread_notifications
            notification = user_notifications.order('created_at DESC').take
          end
          render_success(data: serialize_data(registrar: registrar,
                                              notification: notification,
                                              notifications_count: user_notifications&.count,
                                              object: notification_object(notification)))
        end

        def serialized_domain_transfer(object)
          {
            name: object.domain_name, trStatus: object.status,
            reID: object.new_registrar.code,
            reDate: object.transfer_requested_at.try(:iso8601),
            acID: object.old_registrar.code,
            acDate: object.transferred_at.try(:iso8601) || object.wait_until.try(:iso8601),
            exDate: object.domain_valid_to.iso8601
          }
        end

        def serialized_contact_update_action(object)
          {
            contacts: object.to_non_available_contact_codes,
            operation: object.operation,
            opDate: object.created_at.utc.xmlschema,
            svTrid: object.id,
            who: object.user.username,
            reason: 'Auto-update according to official data',
          }
        end

        private

        # rubocop:disable Style/RescueStandardError
        def notification_object(notification)
          return unless notification&.attached_obj_type || notification&.attached_obj_id

          object_by_type(notification.attached_obj_type).find(notification.attached_obj_id)
        rescue => e
          # the data model might be inconsistent; or ...
          # this could happen if the registrar does not dequeue messages,
          # and then the domain was deleted
          # SELECT messages.id, domains.name, messages.body FROM messages LEFT OUTER
          # JOIN domains ON attached_obj_id::INTEGER = domains.id
          # WHERE attached_obj_type = 'Epp::Domain' AND name IS NULL;
          message = 'orphan message, domain deleted, registrar should dequeue: '
          Rails.logger.error message + e.to_s
        end
        # rubocop:enable Style/RescueStandardError

        def object_by_type(object_type)
          Object.const_get(object_type)
        rescue NameError
          Object.const_get("Version::#{object_type}")
        end

        # rubocop:disable Metrics/MethodLength
        def serialize_data(registrar:, notification:, notifications_count:, object: nil)
          data = current_user.as_json(only: %i[id username])
          data[:registrar_name] = registrar.name
          data[:registrar_reg_no] = registrar.reg_no
          data[:last_login_date] = last_login_date
          data[:domains] = registrar.domains.count
          data[:contacts] = registrar.contacts.count
          data[:phone] = registrar.phone
          data[:email] = registrar.email
          data[:billing_email] = registrar.billing_email
          data[:billing_address] = registrar.address
          data[:notification] = serialized_notification(notification, object)
          data[:notifications_count] = notifications_count
          data
        end
        # rubocop:enable Metrics/MethodLength

        def last_login_date
          q = ApiLog::ReppLog.ransack({ request_path_eq: '/repp/v1/registrar/auth',
                                        response_code_eq: '200',
                                        api_user_name_cont: current_user.username,
                                        request_method_eq: 'GET' })
          q.sorts = 'id desc'
          q.result.offset(1).first&.created_at
        end

        def serialized_notification(notification, object)
          return unless notification

          notification.created_at = notification.created_at.utc.xmlschema
          obj_data = serialized_object(object, notification.attached_obj_type)
          notification.as_json(only: %i[id text created_at attached_obj_id attached_obj_type])
                      .merge({ attached_obj_data: obj_data })
        end

        def serialized_object(object, obj_type)
          return unless object

          try("serialized_#{obj_type.underscore}", object)
        end
      end
    end
  end
end
