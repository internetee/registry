require "rails_helper"

describe Registrar do
  it { should belong_to(:country) }
  it { should have_many(:domains) }
  it { should have_many(:ns_sets) }
  it { should have_many(:epp_users) }
end
