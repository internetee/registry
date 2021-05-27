module Builder
  class XmlMarkup
    def epp_head
      instruct!
      epp(
        'xmlns' => ::Xsd::Schema.filename(for_prefix: 'epp-ee'),
        'xmlns:xsi' => 'http://www.w3.org/2001/XMLSchema-instance',
        'xsi:schemaLocation' => 'lib/schemas/epp-ee-1.0.xsd'
      ) do
        yield
      end
    end
  end
end
