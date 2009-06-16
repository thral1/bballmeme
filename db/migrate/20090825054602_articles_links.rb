class ArticlesLinks < ActiveRecord::Migration
  def self.up
    create_table :articles_links, :id => false do |t|
      t.references :link
      t.references :article
    end
  end

  def self.down
    drop_table :articles_links
  end
end
