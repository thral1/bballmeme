class AddNumTeamsMentionedToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :num_teams_mentioned, :integer
  end

  def self.down
    remove_column :articles, :num_teams_mentioned
  end
end
