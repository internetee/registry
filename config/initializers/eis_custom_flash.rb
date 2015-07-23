module ActionDispatch
  class Flash
    def call(env)
      @app.call(env)
    ensure
      session    = Request::Session.find(env) || {}
      flash_hash = env[KEY]

      if flash_hash && (flash_hash.present? || session.key?('flash'))
        session["flash"] = flash_hash.to_session_value
        Rails.logger.info "FLASH: #{Time.now.to_s(:db)} #{session['flash']['flashes'].inspect}" if session['flash']
        env[KEY] = flash_hash.dup
      end

      if (!session.respond_to?(:loaded?) || session.loaded?) && # (reset_session uses {}, which doesn't implement #loaded?)
        session.key?('flash') && session['flash'].nil?
        session.delete('flash')
      end
    end
  end
end

