class AddLoginAttemptsToUsers < ActiveRecord::Migration
  def change
    add_column :skyline_users, :login_attempts, :integer, :default => 0
    add_column :skyline_users, :last_login_attempt, :timestamp
  end
end
