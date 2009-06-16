class UpdateRssDescriptionLimitInArticles < ActiveRecord::Migration
  def self.up
      change_column :articles, :rss_description, :string, :limit => 2000
  end

  def self.down
      change_column :articles, :rss_description, :string
  end
end
