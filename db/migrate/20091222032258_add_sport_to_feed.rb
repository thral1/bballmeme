class AddSportToFeed < ActiveRecord::Migration
  def self.up
    add_column :feeds, :sport, :string
  end

  def self.down
    remove_column :feeds, :sport
  end
end
