require 'rails_helper'

RSpec.describe UserPresenter do
  let(:presenter) { described_class.new(user: user, view: view) }

  describe '#login_with_role' do
    let(:user) { instance_double(ApiUser,
                                 login: 'login',
                                 roles: %w[role],
                                 registrar_name: 'registrar') }

    it 'returns username with role and registrar' do
      expect(presenter.login_with_role).to eq('login (role) - registrar')
    end
  end
end
