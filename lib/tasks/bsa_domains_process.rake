namespace :bsa_domains do
  desc 'Check closed disputes with expired_at in the Past'
  task call: :environment do
    # Flow state proccess should be like this:
    # QueuedForActivation -> ActivationInProgress -> Active

    FetchGodaddyBsaBlockOrderListJob.perform_now

    UpdateGodaddyDomainsStatusJob.perform_now(
      BsaProtectedDomain.states['QueuedForActivation'],
      BsaProtectedDomain.states['ActivationInProgress']
    )

    UpdateGodaddyDomainsStatusJob.perform_now(
      BsaProtectedDomain.states['ActivationInProgress'],
      BsaProtectedDomain.states['Active']
    )
  end
end
