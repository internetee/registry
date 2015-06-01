module Iptable
  def counter_update(registrar_code, ip)
    counter_proc = "/proc/net/xt_recent/#{registrar_code}"

    begin
      File.open(counter_proc, 'a') do |f|
        f.puts "+#{ip}"
      end
    rescue Errno::ENOENT => e
      logger.error "IPTABLES COUNTER UPDATE: cannot open #{counter_proc}: #{e}"
    rescue Errno::EACCES => e
      logger.error "IPTABLES COUNTER UPDATE: no permission #{counter_proc}: #{e}"
    rescue IOError => e
      logger.error "IPTABLES COUNTER UPDATE: cannot write #{ip} to #{counter_proc}: #{e}"
    end
  end
end
