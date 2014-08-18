require "rails_helper"

describe Setting do
  it { should belong_to(:setting_group) }
end
