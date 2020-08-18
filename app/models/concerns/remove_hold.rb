module RemoveHold
  extend ActiveSupport::Concern

  def remove_hold(params)
    xml = epp_xml.update(name: { value: params[:domain_name] },
                         rem: [status: { attrs: { s: 'clientHold' }, value: '' }])
    current_user.request(xml)
  end
end
