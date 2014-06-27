xml.epp_head do
  xml.response do
    xml.result('code' => params[:code]) do
      xml.msg(params[:msg], 'lang' => 'en')
    end
  end

  xml.trID do
    xml.clTRID params[:clTRID]
  end
end
