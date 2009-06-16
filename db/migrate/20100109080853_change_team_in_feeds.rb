class ChangeTeamInFeeds < ActiveRecord::Migration
  def self.up
     change_column :feeds, :team, :string
  end

  def self.down
      change_column :feeds, :team, :integer
  end
end
