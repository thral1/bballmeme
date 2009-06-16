class AddHideToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :hide, :bool
  end

  def self.down
    remove_column :articles, :hide
  end
end
