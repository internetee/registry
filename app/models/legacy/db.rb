module Legacy
  class Db < ActiveRecord::Base
    self.abstract_class = true
    establish_connection :fred

    def readonly?
      true
    end
  end
end
