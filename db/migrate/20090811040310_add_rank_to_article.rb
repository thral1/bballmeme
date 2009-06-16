class AddRankToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :rank, :float
  end

  def self.down
    remove_column :articles, :rank
  end
end
