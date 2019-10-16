PDFKit.configure do |config|
  config.default_options = {
    page_size: 'A4',
    quiet: true,
    encoding: 'utf-8',
    # :print_media_type => true
  }
end
