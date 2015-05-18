xml.epp_head do
  xml.response do
    xml.result('code' => '1001') do
      xml.msg 'Command completed successfully; action pending'
    end
  end

  xml << render('/epp/shared/trID')
end
