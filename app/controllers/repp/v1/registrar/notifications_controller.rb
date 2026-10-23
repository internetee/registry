module Repp
  module V1
    module Registrar
      class NotificationsController < BaseController
        before_action :set_notification, only: %i[update show]

        THROTTLED_ACTIONS = %i[all_notifications index show update].freeze
        include Shunter::Integration::Throttle

        api :GET, '/repp/v1/registrar/notifications'
        desc 'Get the latest unread poll message'
        def index
          @notification = current_user.unread_notifications.order('created_at DESC').take

          # rubocop:disable Style/AndOr
          render_success(data: nil) and return unless @notification
          # rubocop:enable Style/AndOr

          data = serialized_notification(@notification)

          render_success(data: data)
        end

        api :GET, '/repp/v1/registrar/notifications/all_notifications'
        desc 'Get the all unread poll messages'
        def all_notifications
          records = current_user.unread_notifications.order('created_at DESC').all

          @notification = records.limit(limit).offset(offset)
          # rubocop:disable Style/AndOr
          render_success(data: nil) and return unless @notification
          # rubocop:enable Style/AndOr

          data = @notification.map { |notification| serialized_notification(notification) }

          message = 'Command completed successfully.'\
                    " Returning #{@notification.count} out of #{records.count}."\
                    ' Use URL parameters :limit and :offset to list other messages if needed.'
          render_success(data: data, message: message)
        end

        api :GET, '/repp/v1/registrar/notifications/:notification_id'
        desc 'Get a specific poll message'
        def show
          data = serialized_notification(@notification, include_read: true)

          render_success(data: data)
        end

        api :PUT, '/repp/v1/registrar/notifications'
        desc 'Mark poll message as read'
        param :notification, Hash, required: true do
          param :read, [true, 'true'], required: true, desc: 'Set as true to mark as read'
        end
        def update
          authorize! :manage, :poll
          # rubocop:disable Style/AndOr
          handle_errors(@notification) and return unless @notification.mark_as_read
          # rubocop:enable Style/AndOr

          render_success(data: { notification_id: @notification.id, read: true })
        end

        private

        def serialized_notification(notification, include_read: false)
          fields = %i[id text attached_obj_id attached_obj_type]
          fields << :read if include_read
          data = notification.as_json(only: fields)
          if notification.attached_obj_type == 'DomainAutoRenewal'
            cycle = DomainAutoRenewal.find_by(id: notification.attached_obj_id)
            data[:attached_obj_data] = if cycle
                                         { event: notification.event, domain: cycle.domain_name,
                                           cycle: cycle.as_protocol_json }
                                       end
          end
          data
        end

        def set_notification
          @notification = current_user.unread_notifications.find(params[:id])
        end

        def limit
          index_params[:limit] || 200
        end

        def offset
          index_params[:offset] || 0
        end

        def index_params
          params.permit(:limit, :offset)
        end
      end
    end
  end
end
