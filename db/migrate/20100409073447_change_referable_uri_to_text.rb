class ChangeReferableUriToText < ActiveRecord::Migration
  def self.up
    change_column :skyline_referable_uris, :uri, :text
  end

  def self.down
    change_column :skyline_referable_uris, :uri, :string
  end
end
