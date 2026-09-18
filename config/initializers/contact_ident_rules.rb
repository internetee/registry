# frozen_string_literal: true

default_birthday_restricted_countries = %w[
  BE HR CZ DK FI IT LV LT LU MT NL NO PL PT RO SK SI ES SE EE
]

configured_birthday_restricted_countries = ENV.fetch(
  'birthday_ident_restricted_country_codes',
  default_birthday_restricted_countries.join(',')
)

Rails.configuration.x.contact_ident_birthday_restricted_countries =
  configured_birthday_restricted_countries
    .split(',')
    .map { |code| code.to_s.strip.upcase }
    .reject(&:blank?)
    .uniq
