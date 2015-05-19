Fabricator(:white_ip) do
  ipv4 '192.168.1.1'
  interface WhiteIp::EPP
end

Fabricator(:white_ip_repp, from: :white_ip) do
  ipv4 '127.0.0.1'
  interface WhiteIp::REPP
end
