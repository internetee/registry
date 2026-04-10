module Admin
  class DomainVersionResolver
    attr_reader :version

    def initialize(version)
      @version = version
    end

    def domain
      @domain ||= live_domain || reconstruct_domain
    end

    def deleted?
      live_domain.nil?
    end

    def registrar
      return @registrar if defined?(@registrar)

      @registrar = Registrar.find_by(id: registrar_id)
    end

    def registrar_id
      domain&.registrar_id || changes_value('registrar_id') || object_value('registrar_id')
    end

    def domain_name
      domain&.name || object_value('name') || changes_value('name')
    end

    private

    def live_domain
      return @live_domain if defined?(@live_domain)

      @live_domain = Domain.find_by(id: version.item_id)
    end

    def reconstruct_domain
      reify_with_changes || reify_from_next_version || build_from_changes
    end

    def reify_with_changes
      reified = version.reify
      return nil unless reified

      apply_changes(reified)
      reified
    end

    def reify_from_next_version
      next_version = Version::DomainVersion
                     .where(item_id: version.item_id)
                     .where.not(object: nil)
                     .order(created_at: :asc, id: :asc)
                     .first
      next_version&.reify
    end

    def build_from_changes
      domain = Domain.new
      apply_changes(domain)
      domain
    end

    def apply_changes(domain)
      changes = version.object_changes || {}
      allowed = Domain.column_names
      changes.slice(*allowed).each do |attr, values|
        value = values.is_a?(Array) ? values.last : values
        domain.public_send("#{attr}=", value)
      rescue ArgumentError, TypeError => e
        Rails.logger.warn(
          "DomainVersionResolver: failed to assign #{attr.inspect} " \
          "for version #{version.id}: #{e.class}: #{e.message}"
        )
      end
    end

    def object_value(key)
      version.object.is_a?(Hash) ? version.object[key] : nil
    end

    def changes_value(key)
      changes = version.object_changes
      return nil unless changes.is_a?(Hash) && changes[key].is_a?(Array)

      changes[key].last
    end
  end
end
