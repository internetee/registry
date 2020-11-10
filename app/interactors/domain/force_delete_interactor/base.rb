class Domain
  module ForceDeleteInteractor
    class Base
      include Interactor::Organizer

      # As per https://github.com/collectiveidea/interactor#organizers

      organize Domain::ForceDeleteInteractor::CheckDiscarded,
               Domain::ForceDeleteInteractor::PrepareDomain,
               Domain::ForceDeleteInteractor::SetStatus,
               Domain::ForceDeleteInteractor::PostSetProcess,
               Domain::ForceDeleteInteractor::NotifyRegistrar,
               Domain::ForceDeleteInteractor::NotifyByEmail
    end
  end
end
