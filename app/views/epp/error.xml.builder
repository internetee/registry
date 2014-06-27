xml.epp_head do
  xml.response do
    xml.result('code' => params[:code]) do
      xml.msg(params[:msg], 'lang' => 'en')
    end
  end

  xml << render('/epp/shared/trID')
end
