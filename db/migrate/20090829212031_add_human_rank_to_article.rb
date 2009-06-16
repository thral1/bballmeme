class AddHumanRankToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :human_rank, :integer
  end

  def self.down
    remove_column :articles, :human_rank
  end
end
