Fabricator(:white_ip) do
  ipv4 '127.0.0.1'
  interface WhiteIp::GLOBAL
end

Fabricator(:white_ip_repp, from: :white_ip) do
  interface WhiteIp::REPP
end

Fabricator(:white_ip_epp, from: :white_ip) do
  interface WhiteIp::EPP
end

Fabricator(:white_ip_registrar, from: :white_ip) do
  interface WhiteIp::REGISTRAR
end
