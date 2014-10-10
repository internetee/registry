require 'builder'

class Builder::XmlMarkup
  def epp_head
    self.instruct!
    epp(
      'xmlns' => 'urn:ietf:params:xml:ns:epp-1.0', 
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation' => 'urn:ietf:params:xml:ns:epp-1.0 epp-1.0.xsd'
    ) do
      yield
    end
  end
end
