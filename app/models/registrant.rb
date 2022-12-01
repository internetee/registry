class Registrant < Contact
  # epp_code_map is used during epp domain create
  def epp_code_map
    {}
  end

  def publishable?
    registrant_publishable
  end
end
