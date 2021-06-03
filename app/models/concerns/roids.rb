module Roids
  extend ActiveSupport::Concern
  ID_CHAR_LIMIT = 8

  included do
    def roid
      id_size = id.to_s.size
      if id_size <= ID_CHAR_LIMIT
        "EIS-#{id}"
      else
        roid_with_prefix(id_size)
      end
    end

    private

    def roid_with_prefix(id_size)
      id_delta = id_size - ID_CHAR_LIMIT
      id_prefix = id.to_s.split(//).first(id_delta).join('').to_s
      id_postfix = id.to_s.split(//).last(id_size - id_delta).join('').to_s
      "EIS#{id_prefix}-#{id_postfix}"
    end
  end
end
