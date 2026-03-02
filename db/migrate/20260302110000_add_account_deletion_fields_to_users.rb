# frozen_string_literal: true

class AddAccountDeletionFieldsToUsers < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :account_deletion_token_digest, :string
    add_column :users, :account_deletion_requested_at, :datetime

    add_index :users, :account_deletion_token_digest, unique: true
  end
end
