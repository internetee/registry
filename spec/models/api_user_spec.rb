require 'rails_helper'

describe ApiUser do
  it { should belong_to(:registrar) }
end
