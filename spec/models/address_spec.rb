require "rails_helper"

describe Address do
  it { should belong_to(:contact) }
  it { should belong_to(:country) }
end
