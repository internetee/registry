# frozen_string_literal: true

namespace :auction do
  desc 'Check closed disputes with expired_at in the Past'
  task assign_platform_type: :environment do
    auctions = Auction.where(platform: nil)

    auctions.each do |auction|
      auction.update(platform: :auto)
    end
  end
end
