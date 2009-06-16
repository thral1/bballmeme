class CreateUrlinfos < ActiveRecord::Migration
  def self.up
    create_table :urlinfos do |t|
      t.integer :num_monthly_visitors
      t.integer :site_ranking

      t.timestamps
    end
  end

  def self.down
    drop_table :urlinfos
  end
end
