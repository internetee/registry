module Domains
  module AutoRenew
    ChangeResult = Struct.new(:enabled, :reversed_cycle, :refund_activity, :already_reversed,
                              keyword_init: true)
  end
end
