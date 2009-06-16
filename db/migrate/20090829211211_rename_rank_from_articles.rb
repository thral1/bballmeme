class RenameRankFromArticles < ActiveRecord::Migration
  def self.up
      rename_column :articles, :rank, :score
  end

  def self.down
      rename_column :articles, :score, :rank
  end
end
