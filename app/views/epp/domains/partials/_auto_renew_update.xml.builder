if @auto_renew_requested && epp_session.extension?(EppSession::AUTO_RENEW_URI)
  builder.extension do
    builder.tag!('autoRenew:updData', 'xmlns:autoRenew' => EppSession::AUTO_RENEW_URI) do
      builder.tag!('autoRenew:enabled', @auto_renew_result.enabled.to_s)
      if @auto_renew_result.reversed_cycle
        refund = @auto_renew_result.refund_activity
        builder.tag!('autoRenew:reversed',
                     'cycleId' => @auto_renew_result.reversed_cycle.uuid,
                     'exDate' => @domain.valid_to.iso8601,
                     'refund' => format('%.2f', refund.sum.abs),
                     'currency' => refund.currency,
                     'repeated' => @auto_renew_result.already_reversed.to_s)
      end
    end
  end
end
