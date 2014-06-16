require "rails_helper"

describe NsSet do
  it { should belong_to(:registrar)}
  it { should have_and_belong_to_many(:nameservers) }
end
