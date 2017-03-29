module Concerns::Domain::Disputable
  extend ActiveSupport::Concern

  def disputed?
    @dispute ||= ::Dispute.find_by(domain_name: name)
  end

  def close_dispute
    dispute.close
  end

  alias_method :dispute, :disputed?
end
