FactoryBot.define do
  factory :api_user do
    sequence(:username) { |n| "test#{n}" }
    password 'a' * ApiUser.min_password_length
    roles ['super']
    registrar

    factory :api_user_epp do
      roles %w(epp static_registrant)
    end

    factory :api_user_with_unlimited_balance do
      transient do
        registrar false
      end

      after :build do |api_user, evaluator|
        registrar = (evaluator.registrar || create(:registrar_with_unlimited_balance))
        api_user.registrar = registrar
      end
    end
  end
end
