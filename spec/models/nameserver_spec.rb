require "rails_helper"

describe Nameserver do
  it { should have_and_belong_to_many(:domains) }
end
