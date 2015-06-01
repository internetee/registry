xml.epp_head do
  xml.response do
    xml.result('code' => '1500') do
      xml.msg 'Command completed successfully; ending session'
    end

    render('epp/shared/trID', builder: xml)
  end
end
