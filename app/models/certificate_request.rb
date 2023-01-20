class CertificateRequest < ApplicationRecord
  belongs_to :template_attestation
  belongs_to :user

  has_one_attached :certificate

  enum status_request: {
    created: 1,
    valide: 2,
    invalide: 3
  }
end
