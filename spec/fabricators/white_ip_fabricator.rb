Fabricator(:white_ip) do
  ipv4 '127.0.0.1'
  interfaces [WhiteIp::API]
end

Fabricator(:white_ip_registrar, from: :white_ip) do
  interfaces [WhiteIp::REGISTRAR]
end
