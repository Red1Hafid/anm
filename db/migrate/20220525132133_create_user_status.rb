class CreateUserStatus < ActiveRecord::Migration[7.0]
  def change
    create_table :user_statuses do |t|
      t.string :title
    end
  end
end
