class CreateArticles < ActiveRecord::Migration
  def self.up
    create_table :articles do |t|
      t.string :url
      t.integer :num_visitors_per_month
      t.integer :num_backward_links
      t.integer :length
      t.date :publication_date
      t.integer :rss_feed_level
      t.string :teams_mentioned
      t.string :writer
      t.integer :user_vote_score
      t.string :publication
      t.integer :writer_score
      t.integer :publication_score
      t.text :text

      t.timestamps
    end
  end

  def self.down
    drop_table :articles
  end
end
