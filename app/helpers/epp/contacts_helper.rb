module Epp::ContactsHelper
  def create_contact
    cp = Hash.from_xml(parsed_frame.css("epp command create create").to_xml).with_indifferent_access
  end
end
