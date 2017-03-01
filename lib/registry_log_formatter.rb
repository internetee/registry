class RegistryLogFormatter < ::Logger::Formatter
  def call(severity, timestamp, progname, msg)
    msg = filter_epp_legal_document(msg)
    "#{msg}\n"
  end

  private

  def filter_epp_legal_document(msg)
    msg.gsub(/<eis:legalDocument([^>]+)>([^<])+<\/eis:legalDocument>/,
             "<eis:legalDocument>[FILTERED]</eis:legalDocument>")
  end
end
