# Be sure to restart your server when you modify this file.

secure_cookies = ENV['secure_session_cookies'] == 'true'
same_site_cookies = ENV['same_site_session_cookies'] != 'false' ? ENV['same_site_session_cookies'].to_sym : false

Rails.application.config.session_store :cookie_store,
                                       key: '_registry_session',
                                       secure: secure_cookies,
                                       same_site: same_site_cookies
