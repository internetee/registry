module Auditable
  extend ActiveSupport::Concern
  included do
    PER_PAGE = 7
  end

  def generate_show(klass)
    @version = klass.find(params[:id])
    @versions = versions_scope(klass)
    @versions_map = versions_map(@versions)

    params[:page] = catch_version_page if params[:page].blank?

    @versions = @versions.page(params[:page]).per(PER_PAGE)
  end

  def versions_scope(klass)
    klass.where(object_id: @version.object_id).order(recorded_at: :desc, id: :desc)
  end

  def versions_map(versions)
    versions.all.map(&:id)
  end
end
