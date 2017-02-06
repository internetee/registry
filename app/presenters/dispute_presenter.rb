class DisputePresenter
  def initialize(dispute:, view:)
    @dispute = dispute
    @view = view
  end

  def name
    dispute.domain_name
  end

  private

  attr_reader :dispute
  attr_reader :view
end
