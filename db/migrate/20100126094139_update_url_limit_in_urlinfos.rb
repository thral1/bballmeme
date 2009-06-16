class UpdateUrlLimitInUrlinfos < ActiveRecord::Migration
  def self.up
    change_column :urlinfos, :url, :string, :limit => 350
  end

  def self.down
    change_column :urlinfos, :url, :string
  end
end

