class AddFeedScoreToArticles < ActiveRecord::Migration
  def self.up
    add_column :articles, :feed_score, :integer
  end

  def self.down
    remove_column :articles, :feed_score
  end
end
