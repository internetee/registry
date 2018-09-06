provider_config = { password: ENV['e_invoice_provider_password'],
                    test_mode: ENV['e_invoice_provider_test_mode'] == 'true' }
EInvoice.provider = EInvoice::Providers::OmnivaProvider.new(provider_config)