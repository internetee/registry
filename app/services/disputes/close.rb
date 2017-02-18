module Disputes
  class Close
    def initialize(dispute:)
      @dispute = dispute
    end

    def close
      dispute.destroy
    end

    private

    attr_reader :dispute
  end
end
