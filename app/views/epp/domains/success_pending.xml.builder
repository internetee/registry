xml.epp_head do
  xml.response do
    xml.result('code' => '1001') do
      xml.msg 'Command completed successfully; action pending'
    end
    render('epp/shared/trID', builder: xml)
  end
end
