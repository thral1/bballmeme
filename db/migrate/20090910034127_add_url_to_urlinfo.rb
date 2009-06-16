class AddUrlToUrlinfo < ActiveRecord::Migration
  def self.up
    add_column :urlinfos, :url, :string
  end

  def self.down
    remove_column :urlinfos, :url
  end
end
