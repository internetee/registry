# Please generate production secret with 'rake secret' command
# example secret: 'c831d559c77de1e6544ed4954d5752c294d2390036e45962dc0d44942f20db795ab7b0485b34faf237183660348e3192344404f52df7dee23d8031521d550f89'
Devise.setup do |config|
  config.secret_key = 'please-change'
end
