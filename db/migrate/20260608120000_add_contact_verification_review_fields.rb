# frozen_string_literal: true

class AddContactVerificationReviewFields < ActiveRecord::Migration[6.1]
  disable_ddl_transaction!

  def change
    add_column :contacts, :verification_pending_at, :datetime
    add_column :contacts, :verification_snapshot, :jsonb, default: {}
    add_index :contacts, :verification_pending_at, algorithm: :concurrently
  end
end
