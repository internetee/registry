module Concerns::Domain::Disputable
  extend ActiveSupport::Concern

  def disputed?
    @dispute ||= ::Dispute.for_domain(name)
  end

  def close_dispute
    dispute.close
  end

  alias_method :dispute, :disputed?
end
