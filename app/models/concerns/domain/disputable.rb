module Concerns::Domain::Disputable
  extend ActiveSupport::Concern

  def disputed?
    dispute.present?
  end
end
