module AuctionHelper
  include ActionView::Helpers::TagHelper
  
  extend self

  def colorize_auction(auction)
    case auction.status
    when 'started' then render_status_black(auction.domain)
    when 'awaiting_payment' then render_status_black(auction.domain)
    else render_status_green(auction.domain)
    end
  end

  def render_status_black(name)
    content_tag(:span, name.to_s, style: 'color: black;')
  end

  def render_status_green(name)
    content_tag(:span, name.to_s , style: 'color: green;')
  end
end
