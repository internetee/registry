module Domains
  module Delete
    class Base < ActiveInteraction::Base
      object :domain,
             class: Domain,
             description: 'Domain to delete'
    end
  end
end
