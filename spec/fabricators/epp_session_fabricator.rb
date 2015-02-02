Fabricator(:epp_session) do
  session_id 'test'
  data { { api_user_id: 1 } }
end
