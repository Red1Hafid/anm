class AddReferenceToNote < ActiveRecord::Migration[7.0]
  def change
    add_reference :notes, :project, index: true
  end
end
