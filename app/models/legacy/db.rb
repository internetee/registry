module Legacy
  class Db < ActiveRecord::Base
    self.abstract_class = true
    begin
      establish_connection :fred
    rescue ActiveRecord::AdapterNotSpecified => e
      logger.info "'fred' database not configured, please update your database.yml file: #{e}"
    end

    def readonly?
      true
    end
  end
end
