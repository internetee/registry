Autodoc.configuration.path = 'doc/repp'
Autodoc.configuration.suppressed_request_header = ['Host']
Autodoc.configuration.suppressed_response_header = ['ETag', 'X-Request-Id', 'X-Runtime']
Autodoc.configuration.template = File.read('spec/requests/repp_doc_template.md.erb')
