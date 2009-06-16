class AddRssDescToArticlesTable < ActiveRecord::Migration
  def self.up
    add_column :articles, :rss_description, :string
  end

  def self.down
    remove_column :articles, :rss_description
  end
end
