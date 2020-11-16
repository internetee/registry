class AddSingleAddressPrefixToExistingWhiteIps < ActiveRecord::Migration[6.0]
  def up
    WhiteIp.find_each do |white_ip|
      next if white_ip.ipv4.blank? || white_ip.ipv4.include?('/')

      white_ip.ipv4 << '/32'
      white_ip.save!
    end
  end

  def down
    WhiteIp.find_each do |white_ip|
      next unless white_ip.ipv4.include?('/32')

      white_ip.ipv4 = white_ip.ipv4.gsub('/32', '')
      white_ip.save!
    end
  end
end
