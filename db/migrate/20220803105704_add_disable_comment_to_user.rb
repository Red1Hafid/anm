class AddDisableCommentToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :disable_comment, :text
  end
end
