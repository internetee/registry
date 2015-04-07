module Depp
  module ApplicationHelper
    def unstable_env
      return nil if Rails.env.production?
      Rails.env
    end

    def env_style
      return '' if unstable_env.nil?
      "background-image: url(#{image_path("depp/bg-#{unstable_env}.png")});"
    end

    def ident_for(contact)
      case contact.ident_type
      when 'birthday'
        "#{contact.ident} [#{contact.ident_type}]"
      else
        "#{contact.ident} [#{contact.ident_country_code} #{contact.ident_type}]"
      end
    end

    def pagination_details
      params[:page] ||= 1
      limit = ENV['depp_records_on_page'] || DEPP_RECORDS_ON_PAGE
      offset = ((params[:page].to_i - 1) * limit.to_i)
      [limit, offset]
    end
  end
end
