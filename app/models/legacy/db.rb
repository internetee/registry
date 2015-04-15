module Legacy
  class Db < ActiveRecord::Base
    self.abstract_class = true
    begin
      establish_connection :fred
    rescue ActiveRecord::AdapterNotSpecified => e
      logger.info "Legacy 'fred' database support is currently disabled because #{e}"
    end

    def readonly?
      true
    end
  end
end
