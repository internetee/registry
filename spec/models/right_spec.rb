require "rails_helper"

describe Right do
  it { should have_and_belong_to_many(:roles) }
end
