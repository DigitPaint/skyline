class AddEncryptionMethodToUsers < ActiveRecord::Migration
  def self.up
    add_column :skyline_users, :encryption_method, :string
    execute "UPDATE skyline_users SET encryption_method = 'sha1'"
  end
  
  def self.down
    remove_column :skyline_users, :encryption_method
  end
end
