if !File.respond_to?(:exist?) && File.respond_to?(:exists?)
  File.singleton_class.send(:alias_method, :exist?, :exists?)
elsif !File.respond_to?(:exists?) && File.respond_to?(:exist?)
  File.singleton_class.send(:alias_method, :exists?, :exist?)
end 