# currently identity code generation not implemented,
# thus default user is FI for a while
Fabricator(:admin_user) do
  username 'gitlab'
  password 'ghyt9e4fu'
  password_confirmation 'ghyt9e4fu'
  email 'info@gitlab.eu'
  country_code 'FI'
  roles ['admin']
end

Fabricator(:ee_user, from: :admin_user) do
  identity_code "45002036517"
  country_code 'EE'
  username 'user1'
  password 'testtest'
  password_confirmation 'testtest'
  roles ['admin']
end

# Valid identity codes
# 48805195231
# 45002036517
# 47601126511
# 48802292754
# 45912080223
# 34406056538
# 39503140321
# 39507241618
