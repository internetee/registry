class ExtractUserIdFromEppSessionsData < ActiveRecord::Migration
  def change
    EppSession.all.each do |epp_session|
      user_id = Marshal.load(::Base64.decode64(epp_session.data_before_type_cast))[:api_user_id]
      user = ApiUser.find(user_id)
      epp_session.user = user
      epp_session.save!
    end
  end
end
