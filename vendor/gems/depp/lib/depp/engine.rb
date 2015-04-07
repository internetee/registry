require 'epp-xml'
require 'countries'
require 'depp/sorted_country'
require 'coderay'

module Depp
  class Engine < ::Rails::Engine
    isolate_namespace Depp
  end
end
