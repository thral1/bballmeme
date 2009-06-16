class AddTextToFeedback < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :text, :string
  end

  def self.down
    remove_column :feedbacks, :text
  end
end
