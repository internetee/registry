# builder ||= xml
builder.trID do
  builder.clTRID params[:clTRID] if params[:clTRID].present?
  builder.svTRID @svTRID
end
