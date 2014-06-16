require "rails_helper"

describe Role do
  it { should have_and_belong_to_many(:rights) }
end
