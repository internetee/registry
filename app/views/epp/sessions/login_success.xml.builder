xml.epp_head do
  xml.response do
    xml.result('code' => '1000') do
      xml.msg 'Command completed successfully'
    end
    xml.trID do
      xml.clTRID params[:clTRID]
      xml.svTRID @svTRID
    end
  end
end
