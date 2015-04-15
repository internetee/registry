class Registrar::PollsController < Registrar::DeppController # EPP controller
  before_action :init_epp_xml

  def show
    authorize! :view, :registrar_dashboard
    @data = depp_current_user.request(@ex.poll)
  end

  def destroy
    authorize! :delete, :registrar_poll
    @data = depp_current_user.request(@ex.poll(poll: {
      value: '', attrs: { op: 'ack', msgID: params[:id] }
    }))

    @results = @data.css('result')

    @data = depp_current_user.request(@ex.poll)
    render 'show'
  end

  def confirm_keyrelay
    authorize! :confirm, :keyrelay
    domain_params = params[:domain]
    @data = @domain.confirm_keyrelay(domain_params)

    if response_ok?
      redirect_to info_registrar_domains_url(domain_name: domain_params[:name])
    else
      @results = @data.css('result')
      @data = depp_current_user.request(@ex.poll)
      render 'show'
    end
  end

  def confirm_transfer
    authorize! :confirm, :transfer
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
