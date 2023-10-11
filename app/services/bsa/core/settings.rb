module Bsa
  module Core
    module Settings
      def bsa
        'BSA'
      end
  
      def api_key
        ENV['bsa_api_key']
      end
  
      def base_url
        ENV['bsa_base_url']
      end

      def redist_host
        ENV['bsa_redis_host'] || 'redis'
      end

      def redis_port
        ENV['bsa_redis_port'] || 6379
      end

      def redis_db
        ENV['bsa_redis_db'] || 7
      end
    end
  end
end
