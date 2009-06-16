class MakeUrlUniqueInArticles < ActiveRecord::Migration
  def self.up
        execute "ALTER TABLE articles ADD UNIQUE (url)"
  end

  def self.down
        execute "drop index url on articles"
  end
end
