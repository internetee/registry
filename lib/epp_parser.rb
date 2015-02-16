module EppParser
  def domain_rem_params


    {
      nameservers_attributes: to_destroy
    }
  end

  def nameservers_attributes
    ns_list = Epp::EppDomain.parse_nameservers_from_frame(params[:parsed_frame])

    to_destroy = []
    ns_list.each do |ns_attrs|
      nameserver = @domain.nameservers.where(ns_attrs).try(:first)
      if nameserver.blank?
        epp_errors << {
          code: '2303',
          msg: I18n.t('nameserver_not_found'),
          value: { obj: 'hostAttr', val: ns_attrs[:hostname] }
        }
      else
        to_destroy << {
          id: nameserver.id,
          _destroy: 1
        }
      end
    end
  end
end
