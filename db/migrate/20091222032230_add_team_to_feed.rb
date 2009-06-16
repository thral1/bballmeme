class AddTeamToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :team, :string
  end

  def self.down
    remove_column :feeds, :team
  end
end
