require 'rails_helper'

describe User do
  it { should belong_to(:role) }
  it { should belong_to(:registrar) }
end
