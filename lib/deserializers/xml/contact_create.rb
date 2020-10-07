require 'deserializers/xml/legal_document'
require 'deserializers/xml/ident'
require 'deserializers/xml/contact'

module Deserializers
  module Xml
    class ContactCreate
      attr_reader :frame

      def initialize(frame)
        @frame = frame
      end

      def contact
        @contact ||= ::Deserializers::Xml::Contact.new(frame).call
      end

      def legal_document
        @legal_document ||= ::Deserializers::Xml::LegalDocument.new(frame).call
      end

      def ident
        @ident ||= ::Deserializers::Xml::Ident.new(frame).call
      end
    end
  end
end
