class AddNumberOfItemPaginationToSetting < ActiveRecord::Migration[7.0]
  def change
    add_column :settings, :number_items_of_page, :integer
  end
end
