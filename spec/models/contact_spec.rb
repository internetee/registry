require "rails_helper"

describe Contact do
  it { should have_many(:addresses) }
end
