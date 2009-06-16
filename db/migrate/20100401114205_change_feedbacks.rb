class ChangeFeedbacks < ActiveRecord::Migration
  def self.up
    remove_column :feedbacks, :type
    add_column :feedbacks, :submitter_email, :string
  end

  def self.down
    add_column :feedbacks, :type, :string
    remove_column :feedbacks, :submitter_email
  end
end
