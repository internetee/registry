# Be sure to restart your server when you modify this file.

Rails.application.configure do
  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Add additional assets to the asset load path
  config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts', 'node_modules')
end
