class AddNumCommentsToArticlesTable < ActiveRecord::Migration
  def self.up
    add_column :articles, :num_comments, :integer
  end

  def self.down
    remove_column :articles, :num_comments
  end
end
