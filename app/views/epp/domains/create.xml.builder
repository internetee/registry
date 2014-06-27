xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end
  end

  xml << render('/epp/shared/trID')
end
