xml.epp_head do
  xml.response do
    xml.result('code' => '2306') do
      xml.msg('Parameter value policy error. Allowed only Latin characters.', 'lang' => 'en')
    end
    render('epp/shared/trID', builder: xml)
  end
end
