module Depp
  class Keyrelay
    attr_accessor :current_user, :epp_xml

    def initialize(args = {})
      self.current_user = args[:current_user]
      self.epp_xml = EppXml::Keyrelay.new(cl_trid_prefix: current_user.tag)
    end

    def keyrelay(params)
      custom_params = {}
      if params[:legal_document].present?
        type = params[:legal_document].original_filename.split('.').last.downcase
        custom_params = {
          _anonymus: [
            legalDocument: { value: Base64.encode64(params[:legal_document].read), attrs: { type: type } },
          ],
        }
      end

      xml = epp_xml.keyrelay({
                               name: { value: params['domain_name'] },
                               keyData: {
                                 flags: { value: params['key_data_flags'] },
                                 protocol: { value: params['key_data_protocol'] },
                                 alg: { value: params['key_data_alg'] },
                                 pubKey: { value: params['key_data_public_key'] },
                               },
                               authInfo: {
                                 pw: { value: params['password'] },
                               },
                               expiry: expiry(params['expiry']),
                             }, custom_params)

      current_user.request(xml)
    end

    def expiry(value)
      ISO8601::Duration.new(value)
      { relative: { value: value } }
    rescue StandardError => _e
      { absolute: { value: value } }
    end
  end
end
