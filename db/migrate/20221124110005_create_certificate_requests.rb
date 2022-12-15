class CreateCertificateRequests < ActiveRecord::Migration[7.0]
  def change
    create_table :certificate_requests do |t|
      t.references :template_attestation, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
