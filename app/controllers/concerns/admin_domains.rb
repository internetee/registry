module AdminDomains
  extend ActiveSupport::Concern

  def return_domains_which_related_to_registrars
		if params[:registrar_id_eq]
			domains = Domain.includes(:registrar, :registrant).where(
			registrar: params[:registrar_id_eq]
		)
		else
			domains = Domain.includes(:registrar, :registrant)
		end
  end
end
