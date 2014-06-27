Fabricator(:epp_session) do
  session_id 'test'
  data { {epp_user_id: 1} }
end
