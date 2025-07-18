xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg "Command completed successfully#{@domain.skipped_domain_contacts_validation if @domain && @domain.respond_to?(:skipped_domain_contacts_validation) && @domain.skipped_domain_contacts_validation.present?}"
    end

    render('epp/shared/trID', builder: xml)
  end
end
