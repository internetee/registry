require "rails_helper"

describe EppUser do
  it { should belong_to(:registrar) }
end
