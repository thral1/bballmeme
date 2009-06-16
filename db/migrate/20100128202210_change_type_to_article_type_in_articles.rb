class ChangeTypeToArticleTypeInArticles < ActiveRecord::Migration
  def self.up
    remove_column :articles, :type
    add_column :articles, :article_type, :string
  end

   def self.down
     add_column :articles, :type, :string
     remove_column :articles, :article_type
   end

end
