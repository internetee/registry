# default fabricator should be reusable
Fabricator(:api_user) do
  username { sequence(:username) { |i| "username#{i}" } }
  password 'ghyt9e4fu'
  registrar
  active true
end

# use dedicated fabricator for fixed one
Fabricator(:gitlab_api_user, from: :api_user) do
  username 'gitlab'
end
