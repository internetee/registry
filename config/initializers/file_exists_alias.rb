# В Ruby метод File.exist? является основным, а File.exists? - устаревшим алиасом.
# Однако в некоторых тестах или библиотеках может использоваться именно File.exists?.
# Этот инициализатор добавляет алиас, чтобы оба метода работали корректно.

if !File.respond_to?(:exist?) && File.respond_to?(:exists?)
  # Если exist? не определен, но exists? определен - добавляем алиас exist? -> exists?
  File.singleton_class.send(:alias_method, :exist?, :exists?)
elsif !File.respond_to?(:exists?) && File.respond_to?(:exist?)
  # Если exists? не определен, но exist? определен - добавляем алиас exists? -> exist?
  File.singleton_class.send(:alias_method, :exists?, :exist?)
end 