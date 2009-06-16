class AddAgeToArticle < ActiveRecord::Migration
  def self.up
    add_column :articles, :age, :integer
  end

  def self.down
    remove_column :articles, :age
  end
end
