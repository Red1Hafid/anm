class AddParamsSignatureToFurlough < ActiveRecord::Migration[7.0]
  def change
    add_column :furloughs, :signature_collab, :string
    add_column :furloughs, :signature_g_h, :string
    add_column :furloughs, :signature_g_f, :string
  end
end
