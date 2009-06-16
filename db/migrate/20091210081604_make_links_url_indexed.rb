class MakeLinksUrlIndexed < ActiveRecord::Migration
  def self.up
    add_index :links, :url
  end

  def self.down
    remove_index :links, :url
  end
end
