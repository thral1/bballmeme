class UpdateUrlLimitInArticles < ActiveRecord::Migration
  def self.up
      change_column :articles, :url, :string,  :limit => 350
  end

  def self.down
      change_column :articles, :url, :string
  end
end
