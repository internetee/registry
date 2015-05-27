xml.trID do
  xml.clTRID params[:clTRID] if params[:clTRID].present?
  xml.svTRID @svTRID
end
