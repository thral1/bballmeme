class AddZscoreToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :zscore, :integer
  end

  def self.down
    remove_column :articles, :zscore
  end
end
