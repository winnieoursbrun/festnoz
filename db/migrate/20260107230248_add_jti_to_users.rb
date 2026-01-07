class AddJtiToUsers < ActiveRecord::Migration[8.1]
  def up
    # Add column without null constraint first
    add_column :users, :jti, :string

    # Generate JTI for existing users
    reversible do |dir|
      dir.up do
        execute <<-SQL
          UPDATE users SET jti = gen_random_uuid()::text WHERE jti IS NULL;
        SQL
      end
    end

    # Now add null constraint and unique index
    change_column_null :users, :jti, false
    add_index :users, :jti, unique: true
  end

  def down
    remove_index :users, :jti
    remove_column :users, :jti
  end
end
