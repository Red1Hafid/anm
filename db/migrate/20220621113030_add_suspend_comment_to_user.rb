class AddSuspendCommentToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :suspend_comment, :text
  end
end
