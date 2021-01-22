module Repp
  module V1
    module Registrar
      class NotificationsController < BaseController
        before_action :set_notification, only: [:update]

        api :GET, '/repp/v1/registrar/notifications'
        desc 'Get the latest unread poll message'
        def index
          @notification = current_user.unread_notifications.order('created_at DESC').take
          render_success(data: nil) and return unless @notification

          data = @notification.as_json(only: [:id, :text, :attached_obj_id,
                                              :attached_obj_type])

          render_success(data: data)
        end

        api :GET, '/repp/v1/registrar/notifications/:notification_id'
        desc 'Get a specific poll message'
        def show
          @notification = current_user.registrar.notifications.find(params[:id])
          data = @notification.as_json(only: [:id, :text, :attached_obj_id,
                                              :attached_obj_type])

          render_success(data: data)
        end

        api :PUT, '/repp/v1/registrar/notifications'
        desc 'Mark poll message as read'
        param :notification, Hash, required: true do
          param :read, [true], required: true, desc: "Set as true to mark as read"
        end
        def update
          handle_errors(@notification) and return unless @notification.mark_as_read

          render_success(data: { notification_id: @notification.id, read: true })
        end

        private

        def set_notification
          @notification = current_user.unread_notifications.find(params[:id])
        end
      end
    end
  end
end
