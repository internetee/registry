module Epp::ContactsHelper
  def create_contact
    ccp = contact_create_params
  end

  ### HELPER METHODS ###

  def contact_create_params
    {
      addr: get_params_hash('epp command create create postalInfo addr')
    }
  end
end
