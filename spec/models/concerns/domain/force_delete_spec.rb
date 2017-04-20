require 'rails_helper'

RSpec.describe Domain do
  it { is_expected.to alias_attribute(:force_delete_time, :force_delete_at) }

  before :example do
    Fabricate(:zone, origin: 'ee')
  end

  it 'should set force delete time' do
    domain = Fabricate(:domain)
    domain.statuses = ['ok']
    domain.schedule_force_delete

    domain.statuses.should match_array([
                                         "serverForceDelete",
                                         "pendingDelete",
                                         "serverManualInzone",
                                         "serverRenewProhibited",
                                         "serverTransferProhibited",
                                         "serverUpdateProhibited"
                                       ])

    domain.cancel_force_delete

    domain.statuses.should == ['ok']

    domain.statuses = [
      DomainStatus::CLIENT_DELETE_PROHIBITED,
      DomainStatus::SERVER_DELETE_PROHIBITED,
      DomainStatus::PENDING_UPDATE,
      DomainStatus::PENDING_TRANSFER,
      DomainStatus::PENDING_RENEW,
      DomainStatus::PENDING_CREATE,
      DomainStatus::CLIENT_HOLD,
      DomainStatus::EXPIRED,
      DomainStatus::SERVER_HOLD,
      DomainStatus::DELETE_CANDIDATE
    ]

    domain.save

    domain.schedule_force_delete

    domain.statuses.should match_array([
                                         "clientHold",
                                         "deleteCandidate",
                                         "expired",
                                         "serverForceDelete",
                                         "pendingDelete",
                                         "serverHold",
                                         "serverRenewProhibited",
                                         "serverTransferProhibited",
                                         "serverUpdateProhibited"
                                       ])

    domain.cancel_force_delete

    domain.statuses.should match_array([
                                         "clientDeleteProhibited",
                                         "clientHold",
                                         "deleteCandidate",
                                         "expired",
                                         "pendingCreate",
                                         "pendingRenew",
                                         "pendingTransfer",
                                         "pendingUpdate",
                                         "serverDeleteProhibited",
                                         "serverHold"
                                       ])
  end

  it 'should should be manual in zone and held after force delete' do
    domain = create(:domain)
    Setting.redemption_grace_period = 1

    domain.valid?
    domain.outzone_at = Time.zone.now + 1.day # before redemption grace period
    # what should this be?
    # domain.server_holdable?.should be true
    domain.statuses.include?(DomainStatus::SERVER_HOLD).should be false
    domain.statuses.include?(DomainStatus::SERVER_MANUAL_INZONE).should be false
    domain.schedule_force_delete
    domain.server_holdable?.should be false
    domain.statuses.include?(DomainStatus::SERVER_MANUAL_INZONE).should be true
    domain.statuses.include?(DomainStatus::SERVER_HOLD).should be false
  end

  it 'should not allow update after force delete' do
    domain = create(:domain)
    domain.valid?
    domain.pending_update_prohibited?.should be false
    domain.update_prohibited?.should be false
    domain.schedule_force_delete
    domain.pending_update_prohibited?.should be true
    domain.update_prohibited?.should be true
  end
end
