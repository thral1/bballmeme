class AddSubmitterToFeedback < ActiveRecord::Migration
  def self.up
    add_column :feedbacks, :submitter, :string
  end

  def self.down
    remove_column :feedbacks, :submitter
  end
end
