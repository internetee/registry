module Audit
  class Base < ApplicationRecord
    def diff
      new_value.reject { |k, v| v == old_value[k] }
    end
  end
end
