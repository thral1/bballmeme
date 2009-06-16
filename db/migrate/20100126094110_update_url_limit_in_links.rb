class UpdateUrlLimitInLinks < ActiveRecord::Migration
  def self.up
    change_column :links, :url, :string, :limit => 350
  end

  def self.down
    change_column :links, :url, :string
  end
end
