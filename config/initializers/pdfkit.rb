PDFKit.configure do |config|
  config.wkhtmltopdf = "#{Rails.root}/vendor/bin/wkhtmltopdf"
  config.default_options = {
    page_size: 'A4',
    quiet: true
    # :print_media_type => true
  }
end
