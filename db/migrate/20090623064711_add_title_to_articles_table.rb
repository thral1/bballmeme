class AddTitleToArticlesTable < ActiveRecord::Migration
  def self.up
    add_column :articles, :title, :string
    add_column :articles, :publication_name, :string
    remove_column :articles, :writer
    add_column :articles, :author, :string
  end

  def self.down
    remove_column :articles, :title
    remove_column :articles, :publication_name
    add_column :articles, :writer, :string
    remove_column :articles, :author
  end
end
