class AddUuidToLogRegistrantVerification < ActiveRecord::Migration[5.0]
  def change
    change_table 'log_registrant_verifications' do |t|
      t.string :uuid
    end
  end
end
