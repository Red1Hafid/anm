class AddDateSignatureToCertificateRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :certificate_requests, :date_signature, :date
  end
end
