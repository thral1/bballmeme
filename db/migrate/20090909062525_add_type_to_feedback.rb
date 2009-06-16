class AddTypeToFeedback < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :type, :string
  end

  def self.down
    remove_column :feedbacks, :type
  end
end
