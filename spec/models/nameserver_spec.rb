require 'rails_helper'

describe Nameserver do
  it { should belong_to(:domain) }
end
