cycle_data = cycle.as_protocol_json
attributes = {
  'id' => cycle_data[:id],
  'state' => cycle_data[:state],
  'originalExDate' => cycle_data[:original_expire_time],
  'exDate' => cycle_data[:expire_time],
  'cancelUntil' => cycle_data[:cancellation_deadline],
  'attempts' => cycle_data[:attempts],
}.compact
builder.tag!('autoRenew:cycle', attributes)
