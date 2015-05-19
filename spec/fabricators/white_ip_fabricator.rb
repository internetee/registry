Fabricator(:white_ip) do
  ipv4 '192.168.1.1'
  interface WhiteIp::INTERFACE_EPP
end
