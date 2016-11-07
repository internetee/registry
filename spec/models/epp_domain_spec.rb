require 'rails_helper'

describe Epp::Domain do
  context 'with sufficient settings' do
    let(:domain) { Fabricate(:epp_domain) }
  end
end
