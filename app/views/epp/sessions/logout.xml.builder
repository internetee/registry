xml.epp_head do
  xml.response do
    xml.result('code' => '1500') do
      xml.msg 'Command completed successfully; ending session'
    end
  end

  xml << render('/epp/shared/trID')
end
