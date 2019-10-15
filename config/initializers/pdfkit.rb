PDFKit.configure do |config|
  installed = %x(which wkhtmltopdf).chomp
  if installed == "" then
    installed = "#{Rails.root}/vendor/bin/wkhtmltopdf"
  end
  config.wkhtmltopdf = installed
  config.default_options = {
    page_size: 'A4',
    quiet: true,
    encoding: 'utf-8',
    # :print_media_type => true
  }
end
