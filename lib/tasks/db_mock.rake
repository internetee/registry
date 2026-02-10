namespace :db do
  namespace :seed do
    desc "Load the mock data from db/seeds_mock.rb"
    task mock: :environment do
      load(Rails.root.join('db', 'seeds_mock.rb'))
    end
  end
end
