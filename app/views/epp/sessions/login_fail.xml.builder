xml.epp_head do
  xml.response do
    xml.result('code' => '2501') do
      xml.msg(@msg || 'Authentication error; server closing connection')
    end

    render('epp/shared/trID', builder: xml)
  end
end
