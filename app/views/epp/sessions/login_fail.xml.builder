xml.epp_head do
  xml.response do
    xml.result('code' => '2501') do
      xml.msg('Authentication error; server closing connection')
    end
  end

  xml.trID do
    xml.clTRID params[:clTRID]
    xml.svTRID @svTRID
  end
end
