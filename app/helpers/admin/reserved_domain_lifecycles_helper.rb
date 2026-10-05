module Admin
  module ReservedDomainLifecyclesHelper
    STATUS_CSS_CLASS = {
      'active' => 'label-success',
      'expired' => 'label-danger',
      'released_to_auction' => 'label-info',
      'deleted' => 'label-warning',
      'removed' => 'label-default'
    }.freeze

    def lifecycle_status_css_class(status)
      STATUS_CSS_CLASS.fetch(status, 'label-default')
    end

    def lifecycle_status_label(value)
      audit_value_label(value, ReservedDomain::Lifecycle::STATUSES,
                        'admin.reserved_domain_lifecycles.statuses')
    end

    def lifecycle_source_label(value)
      audit_value_label(value, ReservedDomain::AUDIT_SOURCES,
                        'admin.reserved_domain_lifecycles.sources')
    end

    def lifecycle_yes_no(value)
      value ? t('admin.reserved_domain_lifecycles.yes') : t('admin.reserved_domain_lifecycles.no')
    end

    def lifecycle_reason_label(value)
      audit_value_label(value, ReservedDomain::AUDIT_REASONS,
                        'admin.reserved_domain_lifecycles.reasons')
    end

    private

    # Blank audit fields read as "unknown"; values outside the known
    # vocabulary (shouldn't happen, but the view tolerates them) are
    # shown raw instead of a missing-translation string.
    def audit_value_label(value, known_values, scope)
      return t('admin.reserved_domain_lifecycles.unknown') if value.blank?
      return t("#{scope}.#{value}") if known_values.include?(value)

      value
    end
  end
end
