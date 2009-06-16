class AddTeamsAssociatedToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :teams_associated_with_url, :string
  end

  def self.down
    remove_column :articles, :teams_associated_with_url
  end
end
