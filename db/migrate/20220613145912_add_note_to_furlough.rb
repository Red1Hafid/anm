class AddNoteToFurlough < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :notes, :text, array: true, default: []
  end
end
