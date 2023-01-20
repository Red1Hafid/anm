class AddAttributesToCertificateRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :certificate_requests, :date_refus, :date
    add_column :certificate_requests, :comment_refus, :text
  end
end
