# Be sure to restart your server when you modify this file.

Rails.application.configure do
  # Version of your assets, change this if you want to expire all your assets.
  config.assets.version = '1.0'

  # Add additional assets to the asset load path
  config.assets.paths << Rails.root.join('vendor', 'assets', 'fonts')

  # Precompile additional assets.
  # application.js, application.css, and all non-JS/CSS in app/assets folder are already added.
  config.assets.precompile += %w[login.css registrar-manifest.css shared/pdf.css]
  config.assets.precompile += %w(*.svg *.eot *.woff *.ttf)
  config.assets.precompile += %w(admin-manifest.css admin-manifest.js)
  config.assets.precompile += %w(registrar-manifest.css registrar-manifest.js)
  config.assets.precompile += %w(registrant-manifest.css registrant-manifest.js)
end
