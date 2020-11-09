class Domain
  module ForceDelete
    class Base
      include Interactor::Organizer

      # As per https://github.com/collectiveidea/interactor#organizers

      organize Domain::ForceDelete::CheckDiscarded,
               Domain::ForceDelete::PrepareDomain,
               Domain::ForceDelete::SetStatus,
               Domain::ForceDelete::PostSetProcess,
               Domain::ForceDelete::NotifyRegistrar,
               Domain::ForceDelete::NotifyByEmail
    end
  end
end
