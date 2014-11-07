xml.epp_head do
  xml.response do
    xml.result('code' => '1300') do
      xml.msg 'Command completed successfully; no messages'
    end

    xml << render('/epp/shared/trID')
  end
end
