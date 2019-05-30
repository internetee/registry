class Registrar
  class PollsController < DeppController
    authorize_resource class: false
    before_action :init_epp_xml

    def show
      if Rails.env.test? # Stub for depp server request
        @data = Object.new

        def @data.css(_key)
          []
        end
      else
        @data = depp_current_user.request(@ex.poll)
      end
    end

    def destroy
      @data = depp_current_user.request(@ex.poll(poll: {
                                                   value: '', attrs: { op: 'ack', msgID: params[:id] }
                                                 }))

      @results = @data.css('result')

      @data = depp_current_user.request(@ex.poll)
      render 'show'
    end

    # TODO: Keyrelay is disabled for now
    # def confirm_keyrelay
    #   authorize! :confirm, :keyrelay
    #   domain_params = params[:domain]
    #   @data = @domain.confirm_keyrelay(domain_params)

    #   if response_ok?
    #     redirect_to info_registrar_domains_url(domain_name: domain_params[:name])
    #   else
    #     @results = @data.css('result')
    #     @data = depp_current_user.request(@ex.poll)
    #     render 'show'
    #   end
    # end

    def confirm_transfer
      domain_params = params[:domain]
      @data = @domain.confirm_transfer(domain_params)

      @results = @data.css('result')
      @data = depp_current_user.request(@ex.poll)

      render 'show'
    end

    private

    def init_epp_xml
      @ex = EppXml::Session.new(cl_trid_prefix: depp_current_user.tag)
      @domain = Depp::Domain.new(current_user: depp_current_user)
    end
  end
end
