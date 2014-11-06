require 'rails_helper'

describe Registrar do
  it { should belong_to(:country) }
  it { should have_many(:domains) }
  it { should have_many(:epp_users) }
  it { should have_many(:users) }
  it { should have_many(:messages) }
end
