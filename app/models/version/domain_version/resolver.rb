class Version::DomainVersion < PaperTrail::Version
  class Resolver
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

    def domain_name
      domain.name.presence || object_value('name') || changes_value('name')
    end

    def registrar
      return @registrar if defined?(@registrar)

      @registrar = registrar_id && Registrar.find_by(id: registrar_id)
    end

    def registrar_id
      domain.registrar_id || changes_value('registrar_id') || object_value('registrar_id')
    end

    def item_id
      version.item_id
    end

    private

    def live_domain
      return @live_domain if defined?(@live_domain)

      @live_domain = Domain.find_by(id: version.item_id)
    end

    def reconstruct_domain
      reify_with_changes || earliest_reifiable_version&.reify || build_from_changes
    end

    def reify_with_changes
      reified = version.reify
      return nil unless reified

      apply_changes(reified)
      stamp_timestamps(reified)
      reified
    end

    def earliest_reifiable_version
      sibling_versions.where.not(object: nil).first
    end

    def build_from_changes
      record = Domain.new
      apply_changes(record)
      stamp_timestamps(record)
      record
    end

    def apply_changes(record)
      changes = version.object_changes || {}
      changes.slice(*Domain.column_names).each do |attr, values|
        value = values.is_a?(Array) ? values.last : values
        record.public_send("#{attr}=", value)
      end
    end

    def stamp_timestamps(record)
      record.created_at ||= earliest_version_created_at
      record.updated_at ||= version.created_at
    end

    def earliest_version_created_at
      @earliest_version_created_at ||=
        sibling_versions.pluck(:created_at).first || version.created_at
    end

    def sibling_versions
      Version::DomainVersion
        .where(item_id: version.item_id)
        .order(created_at: :asc, id: :asc)
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
