class Epp::ContactsController < EppController
  before_action :find_contact,  only: [:info, :update, :delete]
  before_action :find_password, only: [:info, :update, :delete]

  def info
    authorize! :info, @contact, @password
    render_epp_response 'epp/contacts/info'
  end

  def check
    authorize! :check, Epp::Contact

    ids = params[:parsed_frame].css('id').map(&:text)
    @results = Contact.check_availability(ids)
    render_epp_response '/epp/contacts/check'
  end

  def create
    authorize! :create, Epp::Contact

    @contact = Epp::Contact.new(params[:parsed_frame])
    @contact.registrar = current_user.registrar

    if @contact.save
      render_epp_response '/epp/contacts/create' 
    else
      handle_errors(@contact)
    end
  end

  def update
    authorize! :update, @contact, @password

    if @contact.update_attributes(params[:parsed_frame])
      render_epp_response 'epp/contacts/update'
    else
      handle_errors(@contact)
    end
  end

  def delete
    authorize! :delete, @contact, @password

    if @contact.destroy_and_clean
      render_epp_response '/epp/contacts/delete'
    else
      handle_errors(@contact)
    end
  end

  def renew
    authorize! :renew, Epp::Contact
    epp_errors << { code: '2101', msg: t(:'errors.messages.unimplemented_command') }
    handle_errors
  end

  private

  def find_password
    @password = params[:parsed_frame].css('authInfo pw').text
  end

  def find_contact
    code = params[:parsed_frame].css('id').text.strip.downcase
    @contact = Epp::Contact.find_by(code: code)

    if @contact.blank?
      epp_errors << { 
        code: '2303',
        msg: t('errors.messages.epp_obj_does_not_exist'),
        value: { obj: 'id', val: code } 
      }
      fail CanCan::AccessDenied
    end
    @contact
  end

  #
  # Validations
  #
  def validate_info
    @prefix = 'info > info >'
    requires 'id'
  end

  def validate_check
    @prefix = 'check > check >'
    requires 'id'
  end

  def validate_create
    @prefix = 'create > create >'
    requires(
      'postalInfo > name', 'postalInfo > addr > city',
      'postalInfo > addr > cc', 'ident', 'voice', 'email'
    )
    @prefix = nil
    requires 'extension > extdata > legalDocument'
  end

  def validate_update
    @prefix = 'update > update >'
    if element_count('chg') == 0 && element_count('rem') == 0 && element_count('add') == 0
      epp_errors << { 
        code: '2003', 
        msg: I18n.t('errors.messages.required_parameter_missing', key: 'add, rem or chg') 
      }
    end
    requires 'id', 'authInfo > pw'
    @prefix = nil
    requires 'extension > extdata > legalDocument'
  end

  def validate_delete
    @prefix = 'delete > delete >'
    requires 'id', 'authInfo > pw'
    @prefix = nil
    requires 'extension > extdata > legalDocument'
  end
end
