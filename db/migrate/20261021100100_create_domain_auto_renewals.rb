class CreateDomainAutoRenewals < ActiveRecord::Migration[6.1]
  def change
    create_table :domain_auto_renewals do |t|
      t.uuid :uuid, null: false, default: -> { 'gen_random_uuid()' }
      t.references :domain, type: :integer, index: false, foreign_key: { on_delete: :nullify }
      t.string :domain_name, null: false
      t.references :registrar, type: :integer, null: false, foreign_key: true
      t.references :account, type: :integer, null: false, index: false, foreign_key: true
      t.string :state, null: false, default: 'awaiting_funds'
      t.datetime :original_expire_at, null: false
      t.datetime :renewed_expire_at
      t.datetime :cancellation_deadline_at, null: false
      t.references :price, type: :integer, index: false, foreign_key: true
      t.references :charge_activity, type: :integer, index: { unique: true },
                                    foreign_key: { to_table: :account_activities }
      t.references :refund_activity, type: :integer, index: { unique: true },
                                    foreign_key: { to_table: :account_activities }
      t.string :failure_reason
      t.integer :attempts_count, null: false, default: 0
      t.datetime :last_attempt_at
      t.datetime :renewed_at
      t.datetime :closed_at
      t.datetime :funding_warning_sent_at
      t.datetime :blocked_warning_sent_at
      t.string :creator_str
      t.string :updator_str
      t.timestamps

      t.check_constraint "state IN ('awaiting_funds', 'grace', 'completed', 'reversed', 'failed', 'cancelled')",
                         name: 'domain_auto_renewals_state_check'
      t.index :uuid, unique: true
      t.index [:domain_id, :original_expire_at], unique: true
      t.index :domain_id, unique: true, where: "state IN ('awaiting_funds', 'grace')"
      t.index [:state, :cancellation_deadline_at], name: 'index_domain_auto_renewals_on_state_and_deadline'
    end
  end
end
