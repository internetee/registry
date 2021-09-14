class Feature
  def self.obj_and_extensions_statuses_enabled?
    return false if ENV['obj_and_extensions_prohibited'] == 'false'

    ENV['obj_and_extensions_prohibited'] || false
  end
end
