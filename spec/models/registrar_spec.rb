require "rails_helper"

describe Registrar do
  it { should belong_to(:country) }
  it { should have_many(:domains) }
  it { should have_many(:ns_sets) }
end
