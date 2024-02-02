module BsaProtectedDomain::Ransackable
  extend ActiveSupport::Concern

  class_methods do
    def ransackable_associations(*)
      authorizable_ransackable_associations
    end

    def ransackable_attributes(*)
      authorizable_ransackable_attributes
    end
  end
end
