class ChangeTeamToInteger < ActiveRecord::Migration
  def self.up
    change_column :feeds, :team, :integer
  end

  def self.down
    change_column :feeds, :team, :string
  end
end
