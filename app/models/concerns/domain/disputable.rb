module Concerns::Domain::Disputable
  extend ActiveSupport::Concern

  def disputed?
    @dispute ||= ::Dispute.for_domain(name)
  end

  alias_method :dispute, :disputed?
end
