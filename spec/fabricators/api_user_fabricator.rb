# default fabricator should be reusable
Fabricator(:api_user) do
  username { sequence(:username) { |i| "username#{i}" } }
  password 'ghyt9e4fu'
  identity_code '14212128025'
  registrar
  active true
  roles ['super']
end

# use dedicated fabricator for fixed one
Fabricator(:gitlab_api_user, from: :api_user) do
  username 'gitlab'
end
