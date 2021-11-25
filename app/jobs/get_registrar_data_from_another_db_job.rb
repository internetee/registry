class GetRegistrarDataFromAnotherDbJob < ApplicationJob
  def perform()
    apiusers_from_test = Actions::GetAccrResultsFromAnotherDb.get_list_of_accredated_users

    apiusers_from_test.each do |r|
      u = User.find_by(name: r.name, ident: r.ident)
      u.accreditation_date = DateTime.zone.now
      u.save
    end

  end


end
