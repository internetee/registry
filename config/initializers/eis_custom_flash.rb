# Log all flash messages
# rubocop: disable Metrics/CyclomaticComplexity
# rubocop: disable Metrics/LineLength
module ActionDispatch
  class Flash
    # rubocop: disable Metrics/PerceivedComplexity
    # rubocop: disable Style/MultilineOperationIndentation
    def call(env)
      @app.call(env)
    ensure
      session    = Request::Session.find(env) || {}
      flash_hash = env[KEY]

      if flash_hash && (flash_hash.present? || session.key?('flash'))
        session["flash"] = flash_hash.to_session_value

        # EIS custom logging
        Rails.logger.info "USER MSG: FLASH: #{session['flash']['flashes'].inspect}" if session['flash']
        # END OF EIS custom logging

        env[KEY] = flash_hash.dup
      end

      if (!session.respond_to?(:loaded?) || session.loaded?) && # (reset_session uses {}, which doesn't implement #loaded?)
        session.key?('flash') && session['flash'].nil?
        session.delete('flash')
      end
    end
  end
end

