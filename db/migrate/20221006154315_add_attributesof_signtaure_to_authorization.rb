class AddAttributesofSigntaureToAuthorization < ActiveRecord::Migration[7.0]
  def change
    add_column :autorizations, :signature_collab, :string
    add_column :autorizations, :signature_g_h, :string
    add_column :autorizations, :signature_g_f, :string
  end
end
