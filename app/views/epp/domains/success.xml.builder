xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end

    render('epp/domains/partials/auto_renew_update', builder: xml) if @auto_renew_requested
    render('epp/shared/trID', builder: xml)
  end
end
