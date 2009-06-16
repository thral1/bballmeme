class AddsiteRankingToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :site_ranking, :integer
  end

  def self.down
    remove_column :articles, :site_ranking
  end
end
