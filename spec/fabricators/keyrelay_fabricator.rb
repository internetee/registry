Fabricator(:keyrelay) do
  pa_date { DateTime.now }
  expiry_relative 'P1W'
end
