module Devise
  module Strategies
    class IdCardAuthenticatable < Devise::Strategies::Authenticatable
      # def valid?
      #   env['SSL_CLIENT_S_DN_CN'].present?
      # end
      #
      # def authenticate!
      #   resource = mapping.to
      #   user = resource.find_by_id_card(id_card)
      #
      #   if user
      #     success!(user)
      #   else
      #     fail
      #   end
      # end
      #
      # private
      #
      # def id_card
      #   id_card = IdCard.new
      #   id_card.first_name = first_name
      #   id_card.last_name = last_name
      #   id_card.personal_code = personal_code
      #   id_card.country_code = country_code
      #   id_card
      # end
      #
      # def first_name
      #   env['SSL_CLIENT_S_DN_CN'].split(',').second.force_encoding('utf-8')
      # end
      #
      # def last_name
      #   env['SSL_CLIENT_S_DN_CN'].split(',').first.force_encoding('utf-8')
      # end
      #
      # def personal_code
      #   env['SSL_CLIENT_S_DN_CN'].split(',').last
      # end
      #
      # def country_code
      #   env['SSL_CLIENT_I_DN_C']
      # end
    end
  end
end

# Warden::Strategies.add(:id_card_authenticatable, Devise::Strategies::IdCardAuthenticatable)
