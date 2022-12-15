class AddStatusToCertificateRequest < ActiveRecord::Migration[7.0]
  def change
    add_column :certificate_requests, :status_request, :integer, default: 1
  end
end
