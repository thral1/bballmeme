class AddPlayersMentionedToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :players_mentioned, :string
  end

  def self.down
    remove_column :articles, :players_mentioned
  end
end
