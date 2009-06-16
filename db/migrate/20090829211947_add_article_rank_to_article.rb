class AddArticleRankToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :article_rank, :integer
  end

  def self.down
    remove_column :articles, :article_rank
  end
end
