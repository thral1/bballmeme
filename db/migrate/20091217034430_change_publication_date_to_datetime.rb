class ChangePublicationDateToDatetime < ActiveRecord::Migration
  def self.up
    change_column :articles, :publication_date, :datetime
  end

  def self.down
    change_column :articles, :publication_date, :date
  end
end
