class Builder::XmlMarkup
  def epp_head
    instruct!
    epp(
      'xmlns' => 'https://epp.tld.ee/schema/epp-ee-1.0.xsd',
      'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
      'xsi:schemaLocation' => 'lib/schemas/epp-ee-1.0.xsd'
    ) do
      yield
    end
  end
end
